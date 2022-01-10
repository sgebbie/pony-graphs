pipeline {
	agent any
	triggers {
		cron('H 4 * * *')
		pollSCM('H/2 * * * *') 
	}
	stages {
		stage('Tooling') {
			steps {
				sh 'ponyc --version'
			}
		}
		stage('Build') {
			steps {
				sh 'ponyc -b pony-graphs .'
				archiveArtifacts artifacts: 'pony-graphs', fingerprint: true
			}
		}
		stage('Test') {
			steps {
				sh './pony-graphs'
			}
		}
	}

	/* set up notifications */
	post {
		always {
			echo 'One way or another, I have finished'
			/* deleteDir() */ /* clean up our workspace */
		}
		success {
			echo 'I succeeeded!'
		}
		unstable {
			echo 'I am unstable :/'
			mail to: "${env.PONY_GRAPHS_NOTIFICATIONS_EMAIL}",
			  subject: "Pipeline unstable: ${currentBuild.fullDisplayName}",
			  body: "The build is unstable: ${env.BUILD_URL}"
		}
		failure {
			echo 'I failed :('
			mail to: "${env.PONY_GRAPHS_NOTIFICATIONS_EMAIL}",
			  subject: "Pipeline failed: ${currentBuild.fullDisplayName}",
			  body: "The build has failed: ${env.BUILD_URL}"
		}
		changed {
			echo 'Things were different before...'
			mail to: "${env.PONY_GRAPHS_NOTIFICATIONS_EMAIL}",
			  subject: "Pipeline status changed: ${currentBuild.fullDisplayName} now ${currentBuild.result}",
			  body: "The status of the build has changed: ${env.BUILD_URL}"
		}
	}
}
