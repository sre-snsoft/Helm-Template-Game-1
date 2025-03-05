{{/* Define a resource limits and requests for microservices */}}
{{- define "resourceRequest" -}}
resources:
  limits:
    cpu: {{ .limits.cpu | default "1" | quote }}
    memory: {{ .limits.memory | default "1" | quote }}
  requests:
    cpu: {{ .requests.cpu | default "1" | quote }}
    memory: {{ .requests.memory | default "1" | quote }}
{{- end }}
{{/*   Generic probe template for startupProbe, readinessProbe, and livenessProbe
  Usage: {{ include "probe" (dict "probe" .startupProbe) | nindent 2 }} */}}
{{- define "probe" -}}
{{ .type }}:
  {{- if eq (.method | toString) "tcpSocket" }}
  tcpSocket:
    {{- with .port }}
    port: {{ . }}
    {{- end }}
  {{- else if eq (.method | toString) "httpGet" }}
  httpGet:
    {{- with .path }}
    path: {{ . }}
    {{- end }}
    {{- with .port }}
    port: {{ . }}
    {{- end }}
  {{- else if eq (.method | toString) "grpc" }}
  grpc:
    {{- with .port }}
    port: {{ . }}
    {{- end }}
  {{- else if eq (.method | toString) "exec" }}
  exec:
    {{- with .command }}
    command: {{ . | toYaml | nindent 6 }}
    {{- end }}
  {{- else }}
    {{- with .custom }}
    {{ . | toYaml | nindent 6 }}
    {{- end }}
  {{- end }}
  {{- with .initialDelaySeconds }}
  initialDelaySeconds: {{ . }}
  {{- end }}
  {{- with .periodSeconds }}
  periodSeconds: {{ . }}
  {{- end }}
  {{- with .successThreshold }}
  successThreshold: {{ . }}
  {{- end }}
  {{- with .failureThreshold }}
  failureThreshold: {{ . }}
  {{- end }}
  {{- with .timeoutSeconds }}
  timeoutSeconds: {{ . }}
  {{- end }}
{{- end }}
