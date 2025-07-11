import jenkins.model.*
import hudson.security.*
import jenkins.install.*

println "Starting Jenkins security configuration..."

def instance = Jenkins.getInstance()

// Skip setup wizard
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

// Only configure security if not already configured
if (instance.getSecurityRealm() == null) {
    println "First boot detected - setting up admin user and security"
    
    // Create admin user
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    hudsonRealm.createAccount("admin", "admin123")
    instance.setSecurityRealm(hudsonRealm)

    // Set authorization strategy - Matrix-based security (restrictive)
    def strategy = new GlobalMatrixAuthorizationStrategy()
    strategy.add(Jenkins.ADMINISTER, "admin")
    strategy.add(Jenkins.READ, "admin")
    instance.setAuthorizationStrategy(strategy)

    // Disable signup
    instance.setDisableSignup(true)

    // Save configuration
    instance.save()
    
    println "Jenkins security configuration completed!"
    println "Username: admin"
    println "Password: admin123"
} else {
    println "Jenkins already configured - skipping security setup"
}
