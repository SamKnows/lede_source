def native_image_version = 1

pipeline {
  agent {
    label 'toolchain_docker'
  }

  options {
    disableConcurrentBuilds()
  }

  stages {
    stage('Update feeds') {
      steps {
        sh label:  'Update feeds',
           script: 'scripts/feeds update -a'
        sh label:  'Remove state',
           script: 'rm -r staging_dir tmp'
      }
    }

    stage('Build') {
      agent {
        docker {
          image "docker.samknows.com/toolchain-native:${native_image_version}"
          args  "-v ${env.WORKSPACE}:/opt/samknows/openwrt_turris_omnia:rw,z"
          reuseNode true
        }
      }

      steps {
        sh label:  'Build',
           script: "cd /opt/samknows/openwrt_turris_omnia && \
                    chmod 400 files/etc/dropbear/authorized_keys && \
                    scripts/feeds install -a && \
                    git checkout -- .config && make defconfig && \
                    make -j \$(getconf _NPROCESSORS_ONLN) -l \$(( 2 * \$(getconf _NPROCESSORS_ONLN) ))"
      }
    }

    stage('Repackage toolchain') {
      stages {
        stage('Uncompress toolchain') {
          steps {
            sh label:  'Prepare directory',
               script: 'mkdir repackaged_toolchain && \
                        cd repackaged_toolchain && \
                        tar --strip-components=1 -xf ../bin/targets/*/*/openwrt-sdk-*.tar.xz'
          }
        }

        stage('Compress toolchain') {
          agent {
            docker {
              image "docker.samknows.com/toolchain-native:${native_image_version}"
              args  "-v ${env.WORKSPACE}/repackaged_toolchain:/opt/samknows/openwrt_turris_omnia:ro,z"
              reuseNode true
            }
          }

          steps {
            sh "cd / && \
                tar czf ${env.WORKSPACE}/turris_omnia_toolchain.tar.gz /opt/samknows/openwrt_turris_omnia"
          }
        }
      }
    }
  }
}
