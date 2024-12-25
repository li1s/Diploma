package test

import (
	"bytes"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"testing"
	"text/template"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"golang.org/x/crypto/ssh"
)

// Generate public & private keys and metadata.yaml
func genSSHKeys(m *testing.M) []byte {
	privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		log.Fatalf("Failed to generate private key: %v", err)
	}

	// Create PEM block from private key
	privateKeyPEM := &pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: x509.MarshalPKCS1PrivateKey(privateKey),
	}

	// Encode private key to SSH format
	privateKeyBytes := pem.EncodeToMemory(privateKeyPEM)

	// Generate public key from private key
	publicKey := &privateKey.PublicKey

	// Serialize public key to authorized_keys format
	authorizedKeyBytes, err := ssh.NewPublicKey(publicKey)
	if err != nil {
		log.Fatalf("Failed to serialize public key: %v", err)
	}
	authorizedKey := ssh.MarshalAuthorizedKey(authorizedKeyBytes)

	// Create /root/.ssh/ directory
	sshDir := "/root/.ssh/"
	if err := os.MkdirAll(sshDir, 0755); err != nil {
		log.Fatal(err)
	}

	// Write private key and public key to files
	err = os.WriteFile(filepath.Join(sshDir, "id_rsa"), privateKeyBytes, 0600)
	if err != nil {
		log.Fatalf("Failed to write private key to file: %v", err)
	}
	err = os.WriteFile(filepath.Join(sshDir, "id_rsa.pub"), authorizedKey, 0644)
	if err != nil {
		log.Fatalf("Failed to write public key to file: %v", err)
	}
	return authorizedKey
}

// Generate pub_keys.txt
func genMetadata(m *testing.M, authorizedKey []byte) {
	const metadata = `astra:{{.Key}}`

	type SSHRsa struct {
		Key string
	}

	// Generate metadata.yaml
	data := SSHRsa{
		Key: string(authorizedKey),
	}

	// Parse the template
	t, err := template.New("pub-keys-template").Parse(metadata)
	if err != nil {
		log.Fatalf("Failed to parse template: %v", err)
	}

	var buf bytes.Buffer

	// Execute the template and write the output to the file
	err = t.Execute(&buf, data)
	if err != nil {
		log.Fatalf("Failed to execute template: %v", err)
	}

	err = os.WriteFile(filepath.Join("managed_k8s", "pub_keys.txt"), []byte(buf.Bytes()), 0644)
	if err != nil {
		log.Fatalf("Failed to write template: %v", err)
	}
}

// Generate .terraformrc
func genTerraformrc(m *testing.M) {
	fileContent := `provider_installation {
	network_mirror {
		url = "https://terraform-mirror.yandexcloud.net/"
		include = ["registry.terraform.io/*/*"]
	}
	direct {
		exclude = ["registry.terraform.io/*/*"]
	}
}`
	// Write file content
	err := os.WriteFile("/root/.terraformrc", []byte(fileContent), 0644)
	if err != nil {
		fmt.Printf("Failed to write file: %v\n", err)
		return
	}
}

// SetUp test environment
func TestMain(m *testing.M) {
	authorizedkey := genSSHKeys(m)
	genMetadata(m, authorizedkey)
	genTerraformrc(m)
	exitCode := m.Run()
	os.Exit(exitCode)
}

// Tests
func TestRequiredVars(t *testing.T) {
	requiredVars := []string{
		"TF_VAR_cloud_id",
		"TF_VAR_folder_id",
		"TF_VAR_network_id",
		"TF_VAR_folder_id_interconnect",
	}

	for _, v := range requiredVars {
		value := os.Getenv(v)
		assert.NotEmpty(t, value, fmt.Sprintf("%s should not be empty", v))
	}
}

func getTerraformOptions(t *testing.T, terraformDir string) *terraform.Options {
	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,
		EnvVars: map[string]string{
			"TF_VAR_cloud_id":               os.Getenv("TF_VAR_cloud_id"),
			"TF_VAR_folder_id":              os.Getenv("TF_VAR_folder_id"),
			"TF_VAR_network_id":             os.Getenv("TF_VAR_network_id"),
			"TF_VAR_folder_id_interconnect": os.Getenv("TF_VAR_folder_id_interconnect"),
			"TF_CLI_ARGS":                   "-no-color",
		},
	})
}

func TestManagedCluster(t *testing.T) {
	terraformOptions := getTerraformOptions(t, "./managed_k8s")

	defer terraform.Destroy(t, terraformOptions)

	// Run terraform init and apply
	terraform.InitAndApply(t, terraformOptions)

	// Capture Output
	clusterId := terraform.Output(t, terraformOptions, "cluster_id")
	assert.NotEmpty(t, clusterId)

	clusterCACertificate := terraform.Output(t, terraformOptions, "cluster_ca_certificate")
	assert.NotEmpty(t, clusterCACertificate)

	internalV4Endpoint := terraform.Output(t, terraformOptions, "internal_v4_endpoint")
	assert.NotEmpty(t, internalV4Endpoint)

	serviceAccountId := terraform.Output(t, terraformOptions, "service_account_id")
	assert.NotEmpty(t, serviceAccountId)
}
