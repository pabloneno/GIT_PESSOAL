SELECT A6_FILIAL	,A6_ZFILIAL,

CASE	
	WHEN A6_BLOCKED = '1' THEN 'SIM'
	WHEN A6_BLOCKED = '2' THEN 'NAO'
	ELSE  'N/A'
END AS BLOQUEADA
,
CASE	
	WHEN A6_XCONV = '1' THEN 'SIM'
	WHEN A6_XCONV = '2' THEN 'NAO'
	ELSE  'N/A'
END AS CONVENIO,	A6_COD,	A6_AGENCIA,	A6_NUMCON,	A6_NOME	,A6_ITEMCRD, CTD_DESC01
FROM SA6010 A6 WITH (NOLOCK) INNER JOIN CTD010 CTD WITH (NOLOCK) ON (CTD.D_E_L_E_T_ = '' AND CTD_FILIAL = A6_FILIAL AND CTD_ITEM=A6_ITEMCRD)
WHERE A6.D_E_L_E_T_ = ''
AND A6_ITEMCRD <> ''


