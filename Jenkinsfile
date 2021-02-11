def native_image_version = 3

pipeline {
  agent {
    label 'toolchain_docker'
  }

  options {
    disableConcurrentBuilds()
  }

  stages {
    stage('Build') {
      agent {
        docker {
          image "docker.samknows.com/toolchain-base:${native_image_version}"
          args  "-v ${env.WORKSPACE}:/opt/samknows/openwrt_skwb8_v4:rw,z"
          reuseNode true
        }
      }

      steps {
        sh label:  'Build',
           script: "cd /opt/samknows/openwrt_skwb8_v4 && \
                    chmod 400 files/etc/dropbear/authorized_keys && \
                    ./scripts/feeds update -a && \
                    ./scripts/feeds install -a && \
                    git checkout -- .config && \
                    make defconfig && \
                    make -j1 V=s"
      }
    }
  }
}
