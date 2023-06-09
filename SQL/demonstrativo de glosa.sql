SELECT BD6_DTANAL,BD6_NOMUSR AS BENEF, BD6_CODPEG AS PEG,BD6_NUMERO AS NUMGUIA, RTRIM(BD6_CODPRO) + ' - ' + RTRIM(BD6_DESPRO) AS PROCED,
BD6_QTDAPR AS QTDAPR, BDX_QTDGLO AS QTDGLO, BD6_VLRAPR AS VLRAPR, BDX_VLRGLO AS VLRGLO , BD6_VLRPAG AS  VLRPAG
,ISNULL(CAST(CAST(BDX_OBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS OBS
FROM BDX020 BDX WITH (NOLOCK) INNER JOIN BD6020 BD6 WITH (NOLOCK) ON (BDX_CODOPE = BD6_CODOPE
AND BDX_CODLDP = BD6_CODLDP AND BDX_CODPEG = BD6_CODPEG AND BDX_NUMERO = BD6_NUMERO AND BDX_CODPAD = BD6_CODPAD
AND BDX_CODPRO = BD6_CODPRO)
WHERE BDX.D_E_L_E_T_ = ''
AND BD6.D_E_L_E_T_ = ''
AND BDX_CODOPE = '0001'
AND BDX_CODLDP = '0002'
AND BDX_CODPEG='00034964'
ORDER BY BD6_CODPEG, BD6_NUMERO
