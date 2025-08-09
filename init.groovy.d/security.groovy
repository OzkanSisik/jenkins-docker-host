import jenkins.model.*
import hudson.security.*
import jenkins.install.*
import java.util.logging.Logger
import java.util.logging.Level

Logger logger = Logger.getLogger("jenkins.security")

logger.info("Starting Jenkins security configuration...")

def instance = Jenkins.getInstance()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

// Only configure security if not already configured
if (instance.getSecurityRealm() == null) {
    logger.info("First boot detected - setting up admin user and security")
    
    // Get admin password from environment variable (required)
    def adminPassword = System.getenv("JENKINS_ADMIN_PASSWORD")
    
    if (!adminPassword) {
        logger.severe("JENKINS_ADMIN_PASSWORD environment variable is required!")
        logger.severe("Jenkins will not start without a secure admin password.")
        logger.severe("Please set JENKINS_ADMIN_PASSWORD and restart Jenkins.")
        
        // Exit Jenkins startup
        System.exit(1)
    }
    
    try {
        // Create admin user
        def hudsonRealm = new HudsonPrivateSecurityRealm(false)
        hudsonRealm.createAccount("admin", adminPassword)
        instance.setSecurityRealm(hudsonRealm)

        // Set authorization strategy (compatible with newer Jenkins versions)
        def strategy = new GlobalMatrixAuthorizationStrategy()
        strategy.add(Jenkins.ADMINISTER, "admin")
        strategy.add(Jenkins.READ, "admin")
        instance.setAuthorizationStrategy(strategy)

        // Disable signup
        instance.setDisableSignup(true)

        instance.save()

        logger.info("Jenkins security configuration completed successfully")
        logger.info("Login with: admin / [your password]")
        
    } catch (Exception e) {
        logger.severe("Error configuring Jenkins security: " + e.getMessage())
        logger.severe("Jenkins will not start due to security configuration failure.")
        System.exit(1)
    }
    
} else {
    logger.info("Jenkins already configured - skipping security setup")
}
