
SELECT A2_NOME FORNECEDOR,A2_CGC FORNECEDOR,E2_CODRET, SUBSTRING(E2_EMISSAO,5,2) MESBASE ,E2_PREFIXO, E2_NUM ,E2_PARCELA,  E2_TIPO,
 E2_NATUREZ NATUREZA,  E2_BASEPIS, 	 E2_VRETPIS 	, E2_VRETCOF, 	 E2_VRETCSLL 	 SOMA 
FROM SE2020 SE2 join SA2020 SA2 ON (A2_COD+A2_LOJA = E2_FORNECE+E2_LOJA)
WHERE E2_TIPO IN ('NF','RC','FT')
AND SE2.D_E_L_E_T_ <> '*'
and E2_EMISSAO between '20200101' and '20201231'
AND E2_VRETIRF > 0


SELECT A2_NOME FORNECEDOR,A2_CGC FORNECEDOR,E2_CODRET, SUBSTRING(E2_VENCTO,7,2) +'/'+ SUBSTRING(E2_VENCTO,5,2)+'/'+ SUBSTRING(E2_VENCTO,1,4) VENCIMENTO,E2_PREFIXO, E2_NUM ,E2_PARCELA,  E2_TIPO,
 E2_NATUREZ NATUREZA, E2_BASEIRF, E2_VRETIRF
FROM SE2020 SE2 join SA2020 SA2 ON (A2_COD+A2_LOJA = E2_FORNECE+E2_LOJA)
WHERE E2_TIPO IN ('NF','RC','FT')
AND SE2.D_E_L_E_T_ <> '*'
and E2_VENCTO between '20180101' and '20181231'
AND E2_VRETIRF > 0
ORDER BY E2_VENCTO

SELECT * FROM SE5020
WHERE E5_HISTOR LIKE '%SALA%'
AND E5_DATA >= '20200101'

/*
UPDATE SE2020
SET E2_CODRET = '3280'
FROM SE2020 SE2 join SA2020 SA2 ON (A2_COD+A2_LOJA = E2_FORNECE+E2_LOJA)
WHERE E2_TIPO IN ('NF','RC','FT')
AND SE2.D_E_L_E_T_ <> '*'
and E2_BAIXA between '20200101' and '20201231'
AND E2_PIS+E2_COFINS+E2_CSLL > 0
AND A2_NOME LIKE '%COOP%'
*/

SELECT * FROM SA2020
WHERE A2_CGC IN (
'15284704000100',
'13792965000106'
)



UPDATE SE2020
SET E2_CODRET = ED_CODRET
FROM SE2020 SE2 JOIN SED020 SED ON (ED_CODIGO = E2_NATUREZ )
WHERE ED_CODRET <> ''
AND SE2.D_E_L_E_T_ = ''
AND SED.D_E_L_E_T_ = ''
AND E2_EMISSAO >= '20191201'
AND E2_CODRET = ''







SELECT E2_CODRET,E2_PREFIXO,*
FROM SE2020 SE2 join SA2020 SA2 ON (A2_COD+A2_LOJA = E2_FORNECE+E2_LOJA)
WHERE E2_TIPO IN ('NF','RC','FT')
AND SE2.D_E_L_E_T_ <> '*'
and E2_VENCREA between '20190101' and '20191231'
--AND E2_PIS+E2_COFINS+E2_CSLL > 0
anD E2_CODRET = '1708'

UPDATE SE2020
SET E2_CODRET = '1708'
FROM SE2020 SE2 join SA2020 SA2 ON (A2_COD+A2_LOJA = E2_FORNECE+E2_LOJA)
WHERE E2_TIPO IN ('NF','RC','FT')
AND SE2.D_E_L_E_T_ <> '*'
and E2_EMISSAO between '20190101' and '20191231'
AND E2_PIS+E2_COFINS+E2_CSLL > 0
anD E2_CODRET = ''

SELECT E2_CODRET , E2_DTDIRF ,E2_DIRF , *
FROM SE2020
WHERE E2_FILIAL = '01'
AND E2_VENCREA BETWEEN '20190101' AND '20191231'
AND E2_CODRET  NOT IN ('5952','5960','5979')
AND D_E_L_E_T_ = ''
and E2_TIPO IN ('NF','RC','FT')

SELECT E2_DIRF, E2_DTDIRF,E2_CODRET,* 
FROM SE2020
WHERE E2_TITPAI = ''
AND D_E_L_E_T_ <> '*'
and E2_EMISSAO between '20200101' and '20201231'
and E2_NATUREZ IN ('2101003', '410108001','410208001','410208002' ,'410208105','410308001','410208006' )




