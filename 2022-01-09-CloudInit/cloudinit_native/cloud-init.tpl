Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"
MIME-Version: 1.0


%{~ for part in cloud_init_parts ~}
${part}
%{~ endfor ~}
--MIMEBOUNDARY--
