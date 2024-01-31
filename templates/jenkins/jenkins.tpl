controller:
  serviceType: NodePort
  nodePort: ${nodePort}
  #jenkinsUrl: http://192.168.105.9:30000
  # jenkinsUrlProtocol: https
  # serviceType: LoadBalancer
  # ingress:
  #   enabled: true
  #   hostName: jenkins.andre.home
  #   path: /
  jenkinsUser: admin
  persistence:
    enabled: true
  initializeOnce: false
  # installLatestSpecifiedPlugins: true
  image: "andrar/jenkins"
  tag: "main"
  installPlugins: false
  JCasC:
    enabled: true
    defaultConfig: false
    configScripts:
      main-config: |
        jenkins:
          numExecutors: 0
          agentProtocols:
          - "JNLP4-connect"
          - "Ping"
          disabledAdministrativeMonitors:
          - "jenkins.monitor.JavaVersionRecommendationAdminMonitor-11-2024-09-30-WARNING"
          labelAtoms:
          - name: "built-in"
          - name: "kubeagent"
          myViewsTabBar: "standard"
          noUsageStatistics: true
          primaryView:
            all:
              name: "all"
          quietPeriod: 5
          remotingSecurity:
            enabled: true
          scmCheckoutRetryCount: 0
          slaveAgentPort: 50000
          authorizationStrategy:
            loggedInUsersCanDoAnything:
              allowAnonymousRead: false
          securityRealm:
            local:
              allowsSignup: false
              enableCaptcha: false
              users:
              - id: "admin"
                name: "Jenkins Admin"
                password: "admin"
                properties:
                - "apiToken"
                - "mailer"
                - "myView"
                - preferredProvider:
                    providerId: "default"
                - "timezone"
                - "experimentalFlags"
          updateCenter:
            sites:
            - id: "default"
              url: "https://updates.jenkins.io/update-center.json"
          views:
          - all:
              name: "all"
          viewsTabBar: "standard"
        globalCredentialsConfiguration:
          configuration:
            providerFilter: "none"
            typeFilter: "none"
        unclassified:
          buildDiscarders:
            configuredBuildDiscarders:
            - "jobBuildDiscarder"
          enrichedSummaryConfig:
            enrichedSummaryEnabled: false
            httpClientDelayBetweenRetriesInSeconds: 1
            httpClientMaxRetries: 3
            httpClientTimeoutInSeconds: 1
          fingerprints:
            fingerprintCleanupDisabled: false
            storage: "file"
          injectionConfig:
            allowUntrusted: false
            checkForBuildAgentErrors: false
            enabled: false
            enforceUrl: false
            injectCcudExtension: false
            injectMavenExtension: false
          mailer:
            charset: "UTF-8"
            useSsl: false
            useTls: false
          pollSCM:
            pollingThreadCount: 10
          scmGit:
            addGitTagAction: false
            allowSecondFetch: false
            createAccountBasedOnEmail: false
            disableGitToolChooser: false
            globalConfigEmail: "someone@gmail.com"
            globalConfigName: "yourname"
            hideCredentials: false
            showEntireCommitSummaryInChanges: false
            useExistingAccountWithSameEmail: false
        tool:
          git:
            installations:
            - home: "git"
              name: "Default"
          gradle:
            installations:
            - name: "gradle"
              properties:
              - installSource:
                  installers:
                  - gradleInstaller:
                      id: "8.4"
          maven:
            installations:
            - name: "maven"
              properties:
              - installSource:
                  installers:
                  - maven:
                      id: "3.9.5"
          mavenGlobalConfig:
            globalSettingsProvider: "standard"
            settingsProvider: "standard"