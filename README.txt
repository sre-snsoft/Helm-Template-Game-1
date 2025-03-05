Pre-requisited : Installed keda 
#############################################################################################
#Reference
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: keda
  namespace: argocd
  finalizers:
    # This finalizer is for demo purposes, in production remove apps using argocd CLI "argocd app delete workload --cascade"
    # When you invoke argocd app delete with --cascade, the finalizer is added automatically.
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://kedacore.github.io/charts
    targetRevision: 2.16.1
    chart: keda


  destination:
    server: https://kubernetes.default.svc
    namespace: keda
  syncPolicy:
    automated:
      allowEmpty: true
    syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true
#############################################################################################

                  ***************************************************
                  ********************Values.yaml********************
                  ***************************************************
# 1. Keep the imageTag field below the name field for your own script to update the image tag version
global:
  namespace: slotgame-test
  # it will be used for the image repo, your ecr image repo name will be required to be named it like "qat-api" -> Ex: <account-id>.dkr.ecr.ap-southeast-1.amazonaws.com/qat-api:0.01
  ecr: <ecr repo #<account-id>.dkr.ecr.ap-southeast-1.amazonaws.com>
  secret:
    enabled: false
    token: "" # vault token in base256

microservices:
  - name: <service.name>
    imageTag: v1.0.0     # image tag version **MUST BE UNDER - name field**
    ecrName: <the ecr name of your respective service>
    replica: 1        #deployment replica with scaled object is disabled
    progressDeadlineSeconds: 600       # remove this field, if not using
    revisionHistoryLimit: 2       # default revision history limit = 10
    scaledObject:         #scaled object with hpa, extra policy can be added.
      enabled: false 
      minReplicaCount: 1
      maxReplicaCount: 2
      scaleUp:
        stabilizationWindowSeconds: 5 
        selectPolicy: Max
        pod:
          podNumber: 10
          seconds: 30
        percent:
          percentage: 100
          seconds: 60
        extraPolicies: []        # if it's not needed, it can be removed from your values.yaml
      scaleDown:
        stabilizationWindowSeconds: 3600
        selectPolicy: Min
        pod:
          podNumber: 4
          seconds: 60
        percent:
          percentage: 50
          seconds: 60
        extraPolicies: []       # if it's not needed, it can be removed from your values.yaml
      # by default, 2 cron job and 1 cpu utilization will be used to trigger the scaled object replica
      cronOne: 
          start: 00 08 * * *
          end: 00 19 * * *
          desiredReplicas: 1
      cronTwo: 
        start: 00 19 * * *
        end: 00 23 * * *
        desiredReplicas: 1
      cpu:
        utilization: 60
    # The node selector app: <karpenter>, therefore in the nodepool needed to configure it as app: karpenter
    nodeSelector: ""
    command:        # command, if not using can remove it.
      - ""
    args:       # arg, if not using can remove it. It is a list
      - ""
    ports:      # remove the port, if the deployment does not need a port to be configured
      - containerPort: <port>
        name: <port name>
        protocol: TCP
      - containerPort: <port>
        name: <port name>
        protocol: TCP  
    # line 104-108 can be removed, if any of it is not needed
    terminationMessagePath: ""
    terminationMessagePolicy: File
    workingDir: ""
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    # resource request and limit, all of these needed to be set
    limits:
      cpu: 200m         #default 1
      memory: 100Mi         #default 1
    requests:
      cpu: 200m         #default 1
      memory: 100Mi         #default 1
    # enabled based on your needs, available probe (1. startup 2. readiness 3. liveness)
    #  # method options: 1. httpGet 2. grpc 3. exec 4. tcpSocket 5. custom
    # 1. method: exec
      # exec:
      #   command:
      #     - /bin/grpc_health_probe
      #     - -addr=:<port>
      #     - -rpc-timeout=5s
    # 2. method: httpGet
      # httpGet:
      #   path: <path>
      #   port: <port>
    # 3. method: tcpSocket
      # tcpSocket:
      #   port: <port>
    # 4. method: grpc
      # grpc:
      #   port: <port>
    # 5. method: custom
      #   custom: []  define your own method
    startupProbe:
      enabled: false
      method: custom
      custom: []
      initialDelaySeconds: 10
    readinessProbe:
      enabled: true
      method: exec
      command:
        - /bin/grpc_health_probe
        - -addr=:<port>
        - -rpc-timeout=5s
      initialDelaySeconds: 10
    livenessProbe:
      enabled: true
      method: exec
      command:
        - /bin/grpc_health_probe
        - -addr=:<port>
        - -rpc-timeout=5s
      # mutliple fields are avaiable for the each of the probe, include it if u need it
      ## initialDelaySeconds/periodSeconds/successThreshold/failureThreshold/timeoutSeconds
      initialDelaySeconds: 10       # default 30
      periodSeconds: 10       # default 30
      successThreshold: 10       # default 1
      failureThreshold: 10       # default 3
      timeoutSeconds: 10       # default 3
    services:
      # default values (type: ClusterIP, protocol: TCP, targetPort = Port)
      - name: pprof         # service 1
        annotations: []         # can remove this field, if it is not needed
        type: <ClusterIP>         # default is using cluster IP can be configured
        port: <port>
        targetPort: <Targeted port>      # can be set if the targeted port is not same as the port
      - name: grpc          # service 2
        port: <port>
    # only one ingress per service can be set, only annotation and port can be configured
    ingress:
      enabled: false
      annotation: []        # remove this field if its not using
      port: ""
