import jenkins.model.*
import hudson.security.*
import jenkins.install.*

println "Starting Jenkins security configuration..."

def instance = Jenkins.getInstance()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

// Only configure security if not already configured
if (instance.getSecurityRealm() == null) {
    println "First boot detected - setting up admin user and security"
    
    // Get admin password from environment variable or use default
    def adminPassword = System.getenv("JENKINS_ADMIN_PASSWORD") ?: "changeme123!"
    
    // Create admin user
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    hudsonRealm.createAccount("admin", adminPassword)
    instance.setSecurityRealm(hudsonRealm)

    // Set authorization strategy
    def strategy = new GlobalMatrixAuthorizationStrategy()
    strategy.add(Jenkins.ADMINISTER, "admin")
    strategy.add(Jenkins.READ, "admin")
    instance.setAuthorizationStrategy(strategy)

    // Disable signup
    instance.setDisableSignup(true)

    instance.save()

    println "Jenkins security configuration completed!"
} else {
    println "Jenkins already configured - skipping security setup"
}
