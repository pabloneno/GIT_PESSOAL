USE DB_INTEGRACAO_ERP
GO
DECLARE @DIAS INT =0
DECLARE @INICIO DATE = (GETDATE() - @DIAS)
SELECT DESDE = CONVERT(VARCHAR(10),@INICIO,103), HORA = CONVERT(VARCHAR(10),getdate(),108)

SELECT 
	TIPO, ENFILEIRADOS, PROCESSADOS --, MEDIA_TEMPO_EXEC = TEMPOMEDIO, MEDIA_TEMPO_TOTAL = TEMPOESPERA, MEDIA_TEMPO_ESPER = (TEMPOESPERA - TEMPOMEDIO)
	--, ESTIMADO_EM_MINUTOS = (ENFILEIRADOS * ((TEMPOESPERA - TEMPOMEDIO) + TEMPOMEDIO) / 60.0)
	, ULTIMO, MAIS_ANTIGO
FROM
(
select TIPO = 'TITULO A PAGAR'
,ENFILEIRADOS = ISNULL((SELECT count(DISTINCT I.ITPI_CONTROLE) FROM INT_TIT_PAG_IN I WITH (NOLOCK) WHERE NOT EXISTS(SELECT 1 FROM INT_TIT_PAG_OUT O WITH (NOLOCK) WHERE O.ITPO_CONTROLE = I.ITPI_CONTROLE)),0)
,PROCESSADOS = ISNULL((select COUNT(DISTINCT ITPI_CONTROLE) FROM INT_TIT_PAG_IN TPI WITH(NOLOCK), INT_TIT_PAG_OUT TPO WITH(NOLOCK) WHERE TPI.ITPI_CONTROLE = TPO.ITPO_CONTROLE and TPO.ITPO_DATAINTEGRACAO >= @INICIO),0)
,TEMPOMEDIO = ISNULL((select avg(ITPO_TEMPO) FROM INT_TIT_PAG_OUT O WITH(NOLOCK) WHERE O.ITPO_DATAINTEGRACAO >= @INICIO AND ITPO_TEMPO IS NOT NULL),0)
,TEMPOESPERA = ISNULL((select avg(datediff(ss,TPI.ITPI_DATAENTRADA,TPO.ITPO_DATAINTEGRACAO)) FROM INT_TIT_PAG_IN TPI WITH(NOLOCK), INT_TIT_PAG_OUT TPO WITH(NOLOCK) WHERE TPI.ITPI_CONTROLE = TPO.ITPO_CONTROLE and TPO.ITPO_DATAINTEGRACAO >= @INICIO),0)
, ULTIMO =  ISNULL((SELECT MAX(ITPO_DATAINTEGRACAO) FROM INT_TIT_PAG_OUT O WITH (NOLOCK)),0)
, MAIS_ANTIGO = (SELECT MIN(I.ITPI_DATAENTRADA) FROM INT_TIT_PAG_IN I WITH (NOLOCK) WHERE NOT EXISTS(SELECT 1 FROM INT_TIT_PAG_OUT O WITH (NOLOCK) WHERE O.ITPO_CONTROLE = I.ITPI_CONTROLE))
UNION
select TIPO = 'TITULO A RECEBER'
,ENFILEIRADOS = ISNULL((SELECT count(DISTINCT I.ITRI_CONTROLE) FROM INT_TIT_REC_IN I WITH (NOLOCK) WHERE NOT EXISTS(SELECT 1 FROM INT_TIT_REC_OUT O WITH (NOLOCK) WHERE O.ITRO_CONTROLE = I.ITRI_CONTROLE)),0)
,PROCESSADOS = ISNULL((SELECT count(DISTINCT I.ITRI_CONTROLE) FROM INT_TIT_REC_IN I WITH (NOLOCK) WHERE EXISTS(SELECT 1 FROM INT_TIT_REC_OUT O WITH (NOLOCK) WHERE O.ITRO_CONTROLE = I.ITRI_CONTROLE AND O.ITRO_DATAINTEGRACAO >= @INICIO)),0)
,TEMPOMEDIO = ISNULL((SELECT AVG(O.ITRO_TEMPO) FROM INT_TIT_REC_OUT O WITH (NOLOCK) WHERE O.ITRO_DATAINTEGRACAO >= @INICIO),0)
,TEMPOESPERA = ISNULL((select avg(datediff(ss,TRI.ITRI_DATAENTRADA,TRO.ITRO_DATAINTEGRACAO)) FROM INT_TIT_REC_IN TRI WITH(NOLOCK), INT_TIT_REC_OUT TRO WITH(NOLOCK) WHERE TRI.ITRI_CONTROLE = TRO.ITRO_CONTROLE and TRO.ITRO_DATAINTEGRACAO >= @INICIO),0)
, ULTIMO =  ISNULL((SELECT MAX(ITRO_DATAINTEGRACAO) FROM INT_TIT_REC_OUT O WITH (NOLOCK)),0)
,MAIS_ANTIGO = (SELECT MIN(I.ITRI_DATAENTRADA) FROM INT_TIT_REC_IN I WITH (NOLOCK) WHERE NOT EXISTS(SELECT 1 FROM INT_TIT_REC_OUT O WITH (NOLOCK) WHERE O.ITRO_CONTROLE = I.ITRI_CONTROLE))
UNION
select  TIPO = 'CLIENTE'
,ENFILEIRADOS = count(distinct i.ICLI_CONTROLE)
,PROCESSADOS = ISNULL((select COUNT(DISTINCT ICLI_CONTROLE) FROM INT_CLIENTE_IN CLI with (NOLOCK), INT_CLIENTE_OUT CLO WITH(NOLOCK) WHERE CLI.ICLI_CONTROLE = CLO.ICLO_CONTROLE AND CLO.ICLO_DATAINTEGRACAO >= @INICIO),0)
,TEMPOMEDIO = ISNULL((select avg(ICLO_TEMPO) FROM INT_CLIENTE_OUT O WITH(NOLOCK) WHERE O.ICLO_DATAINTEGRACAO >= @INICIO AND ICLO_TEMPO IS NOT NULL),0)
,TEMPOESPERA = ISNULL((select avg(datediff(ss,CLI.ICLI_DATAENTRADA,CLO.ICLO_DATAINTEGRACAO)) FROM INT_CLIENTE_IN CLI with (NOLOCK), INT_CLIENTE_OUT CLO WITH(NOLOCK) WHERE CLI.ICLI_CONTROLE = CLO.ICLO_CONTROLE AND CLI.ICLI_DATAENTRADA >= @INICIO),0)
, ULTIMO =  ISNULL((SELECT MAX(ICLO_DATAINTEGRACAO) FROM INT_CLIENTE_OUT O WITH (NOLOCK)),0)
,MAIS_ANTIGO = MIN(ICLI_DATAENTRADA)
from INT_CLIENTE_IN i (NOLOCK)
WHERE not exists (select 1 from INT_CLIENTE_OUT o (NOLOCK) where o.ICLO_CONTROLE = i.ICLI_CONTROLE)
and not exists(select 1 from INT_TIT_REC_IN r (NOLOCK) where r.ITRI_CONTROLE = i.ICLI_CONTROLE)
and not exists(select 1 from INT_PEDIDO_VENDA_IN p (NOLOCK) where p.IPVI_CONTROLE = i.ICLI_CONTROLE)
AND  I.ICLI_DATAENTRADA >= @INICIO
UNION
select  TIPO = 'FORNECEDOR'
,ENFILEIRADOS = count(distinct i.IFOI_CONTROLE)
,PROCESSADOS = ISNULL((select COUNT(DISTINCT IFOI_CONTROLE) FROM INT_FORNECEDOR_IN FOI WITH(NOLOCK), INT_FORNECEDOR_OUT FOO WITH(NOLOCK) WHERE FOI.IFOI_CONTROLE = FOO.IFOO_CONTROLE and FOO.IFOO_DATAINTEGRACAO >= @INICIO),0)
,TEMPOMEDIO = ISNULL((select avg(IFOO_TEMPO) FROM INT_FORNECEDOR_OUT O WITH(NOLOCK) WHERE O.IFOO_DATAINTEGRACAO >= @INICIO AND IFOO_TEMPO IS NOT NULL),0)
,TEMPOESPERA = ISNULL((select avg(datediff(ss,FOI.IFOI_DATAENTRADA,FOO.IFOO_DATAINTEGRACAO)) FROM INT_FORNECEDOR_IN FOI WITH(NOLOCK), INT_FORNECEDOR_OUT FOO WITH(NOLOCK) WHERE FOI.IFOI_CONTROLE = FOO.IFOO_CONTROLE and FOO.IFOO_DATAINTEGRACAO >= @INICIO),0)
, ULTIMO =  ISNULL((SELECT MAX(IFOO_DATAINTEGRACAO) FROM INT_FORNECEDOR_OUT O WITH (NOLOCK)),0)
,MAIS_ANTIGO = MIN(IFOI_DATAENTRADA)
from INT_FORNECEDOR_IN i (NOLOCK)
WHERE not exists (select 1 from INT_FORNECEDOR_OUT o (NOLOCK) where o.IFOO_CONTROLE = i.IFOI_CONTROLE)
and not exists(select 1 from INT_TIT_PAG_IN r (NOLOCK) where r.ITPI_CONTROLE = i.IFOI_CONTROLE)
and not exists(select 1 from INT_PEDIDO_COMPRA_IN p (NOLOCK) where p.IPCI_CONTROLE = i.IFOI_CONTROLE)
and not exists(select 1 from INT_ESPELHO_NOTA_IN p (NOLOCK) where p.IENI_CONTROLE = i.IFOI_CONTROLE)
AND  I.IFOI_DATAENTRADA >= @INICIO
UNION
select TIPO = 'ESPELHO DA NOTA'
,ENFILEIRADOS = (select count(distinct I.IENI_CONTROLE) from [dbo].[INT_ESPELHO_NOTA_IN] I with (NOLOCK) where not exists(select 1 from [dbo].[INT_ESPELHO_NOTA_OUT] O (NOLOCK) where I.IENI_CONTROLE = O.IENO_CONTROLE))
,PROCESSADOS = ISNULL((select COUNT(DISTINCT IENI_CONTROLE) FROM INT_ESPELHO_NOTA_IN ENI WITH(NOLOCK), INT_ESPELHO_NOTA_OUT ENO WITH(NOLOCK) WHERE ENI.IENI_CONTROLE = ENO.IENO_CONTROLE and ENO.IENO_DATAINTEGRACAO >= @INICIO),0)
,TEMPOMEDIO = ISNULL((select avg(IENO_TEMPO) FROM INT_ESPELHO_NOTA_OUT O WITH(NOLOCK) WHERE O.IENO_DATAINTEGRACAO >= @INICIO AND IENO_TEMPO IS NOT NULL),0)
,TEMPOESPERA = ISNULL((select avg(datediff(ss,ENI.IENI_DATAENTRADA,ENO.IENO_DATAINTEGRACAO)) FROM INT_ESPELHO_NOTA_IN ENI WITH(NOLOCK), INT_ESPELHO_NOTA_OUT ENO WITH(NOLOCK) WHERE ENI.IENI_CONTROLE = ENO.IENO_CONTROLE and ENO.IENO_DATAINTEGRACAO >= @INICIO),0)
,ULTIMO =  ISNULL((SELECT MAX(IENO_DATAINTEGRACAO) FROM INT_ESPELHO_NOTA_OUT O WITH (NOLOCK)),0)
,MAIS_ANTIGO = (select MIN(I.IENI_DATAENTRADA) from [dbo].[INT_ESPELHO_NOTA_IN] I with (NOLOCK) where not exists(select 1 from [dbo].[INT_ESPELHO_NOTA_OUT] O (NOLOCK) where I.IENI_CONTROLE = O.IENO_CONTROLE))
UNION

select TIPO = 'CONTABILIDADE-FOLHA'
,ENFILEIRADOS = count(DISTINCT I.ICOI_CONTROLE)
,PROCESSADOS = ISNULL((select count (distinct iCOI_CONTROLE)FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA = 'DATASUL12' AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE and COO.ICOO_DATAINTEGRACAO >= @INICIO),0)
,TEMPOMEDIO = ISNULL((select avg(COO.ICOO_TEMPO) FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA = 'DATASUL12' AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE AND COO.ICOO_DATAINTEGRACAO >= @INICIO AND COO.ICOO_TEMPO IS NOT NULL),0)
,TEMPOESPERA = 60 * ISNULL((select avg(datediff(MINUTE,COI.ICOI_DATAENTRADA,COO.ICOO_DATAINTEGRACAO)) FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA = 'DATASUL12' AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE and COO.ICOO_DATAINTEGRACAO >= @INICIO),0)
,ULTIMO =  ISNULL((SELECT MAX(ICOO_DATAINTEGRACAO) FROM INT_CONTABILIDADE_OUT O WITH (NOLOCK)),0)
,MAIS_ANTIGO = MIN(ICOI_DATAENTRADA)
from [dbo].[INT_CONTABILIDADE_IN] I (NOLOCK)
LEFT OUTER JOIN [dbo].[INT_CONTABILIDADE_OUT] O (NOLOCK) ON
	O.ICOO_CONTROLE = I.ICOI_CONTROLE 
WHERE 1 = 1
AND  I.ICOI_DATAENTRADA >= @INICIO
AND   O.ICOO_DATAINTEGRACAO IS NULL
and   i.ICOI_SISTEMA = 'DATASUL12'
UNION
select TIPO = 'CONTABILIDADE-OUTROS'
,ENFILEIRADOS = count(DISTINCT I.ICOI_CONTROLE)
,PROCESSADOS = ISNULL((select count (distinct iCOI_CONTROLE)FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA NOT IN ('DATASUL12','TOTVS EDUCACIONAL','WBC') AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE and COO.ICOO_DATAINTEGRACAO >= @INICIO),0)
,TEMPOMEDIO = ISNULL((select avg(COO.ICOO_TEMPO) FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA NOT IN ('DATASUL12','TOTVS EDUCACIONAL','WBC') AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE AND COO.ICOO_DATAINTEGRACAO >= @INICIO AND COO.ICOO_TEMPO IS NOT NULL),0)
,TEMPOESPERA = 60 * ISNULL((select avg(datediff(MINUTE,COI.ICOI_DATAENTRADA,COO.ICOO_DATAINTEGRACAO)) FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA NOT IN ('DATASUL12','TOTVS EDUCACIONAL','WBC') AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE and COO.ICOO_DATAINTEGRACAO >= @INICIO),0)
, ULTIMO =  ISNULL((SELECT MAX(ICOO_DATAINTEGRACAO) FROM INT_CONTABILIDADE_OUT O WITH (NOLOCK)),0)
, MAIS_ANTIGO = MIN(ICOI_DATAENTRADA)
from [dbo].[INT_CONTABILIDADE_IN] I (NOLOCK)
LEFT OUTER JOIN [dbo].[INT_CONTABILIDADE_OUT] O (NOLOCK) ON
	O.ICOO_CONTROLE = I.ICOI_CONTROLE 
WHERE 1 = 1
AND   O.ICOO_DATAINTEGRACAO IS NULL
and   i.ICOI_SISTEMA NOT IN ('DATASUL12','TOTVS EDUCACIONAL','WBC')
UNION
select TIPO = 'CONTABILIDADE-RM'
,ENFILEIRADOS = count(DISTINCT I.ICOI_CONTROLE)
,PROCESSADOS = ISNULL((select count (distinct iCOI_CONTROLE)FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA = 'TOTVS EDUCACIONAL' AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE and COO.ICOO_DATAINTEGRACAO >= @INICIO),0)
,TEMPOMEDIO = ISNULL((select avg(COO.ICOO_TEMPO) FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA = 'TOTVS EDUCACIONAL' AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE AND COO.ICOO_DATAINTEGRACAO >= @INICIO AND COO.ICOO_TEMPO IS NOT NULL),0)
,TEMPOESPERA = 60 * ISNULL((select avg(datediff(MINUTE,COI.ICOI_DATAENTRADA,COO.ICOO_DATAINTEGRACAO)) FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA = 'TOTVS EDUCACIONAL' AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE and COO.ICOO_DATAINTEGRACAO >= @INICIO),0)
, ULTIMO =  ISNULL((SELECT MAX(ICOO_DATAINTEGRACAO) FROM INT_CONTABILIDADE_OUT O WITH (NOLOCK)),0)
, MAIS_ANTIGO = MIN(ICOI_DATAENTRADA)
from [dbo].[INT_CONTABILIDADE_IN] I (NOLOCK)
LEFT OUTER JOIN [dbo].[INT_CONTABILIDADE_OUT] O (NOLOCK) ON
	O.ICOO_CONTROLE = I.ICOI_CONTROLE 
WHERE 1 = 1
AND   O.ICOO_DATAINTEGRACAO IS NULL
and   i.ICOI_SISTEMA = 'TOTVS EDUCACIONAL'
UNION
select TIPO = 'CONTABILIDADE-WBC'
,ENFILEIRADOS = count(DISTINCT I.ICOI_CONTROLE)
,PROCESSADOS = ISNULL((select count (distinct iCOI_CONTROLE)FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA = 'WBC' AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE and COO.ICOO_DATAINTEGRACAO >= @INICIO),0)
,TEMPOMEDIO = ISNULL((select avg(COO.ICOO_TEMPO) FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA = 'WBC' AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE AND COO.ICOO_DATAINTEGRACAO >= @INICIO AND COO.ICOO_TEMPO IS NOT NULL),0)
,TEMPOESPERA = 60 * ISNULL((select avg(datediff(MINUTE,COI.ICOI_DATAENTRADA,COO.ICOO_DATAINTEGRACAO)) FROM INT_CONTABILIDADE_IN COI WITH(NOLOCK), INT_CONTABILIDADE_OUT COO WITH(NOLOCK) WHERE COI.ICOI_SISTEMA = 'WBC' AND COI.ICOI_CONTROLE = COO.ICOO_CONTROLE and COO.ICOO_DATAINTEGRACAO >= @INICIO),0)
, ULTIMO =  ISNULL((SELECT MAX(ICOO_DATAINTEGRACAO) FROM INT_CONTABILIDADE_OUT O WITH (NOLOCK)),0)
, MAIS_ANTIGO = MIN(ICOI_DATAENTRADA)
from [dbo].[INT_CONTABILIDADE_IN] I (NOLOCK)
LEFT OUTER JOIN [dbo].[INT_CONTABILIDADE_OUT] O (NOLOCK) ON
	O.ICOO_CONTROLE = I.ICOI_CONTROLE 
WHERE 1 = 1
AND   O.ICOO_DATAINTEGRACAO IS NULL
and   i.ICOI_SISTEMA = 'WBC'
UNION
select TIPO = 'PEDIDO VENDA'
,ENFILEIRADOS = count(DISTINCT I.IPVI_CONTROLE)
,PROCESSADOS = ISNULL((select count(distinct IPVI_CONTROLE) FROM INT_PEDIDO_VENDA_IN PVI WITH(NOLOCK), INT_PEDIDO_VENDA_OUT PVO WITH(NOLOCK) WHERE PVI.IPVI_CONTROLE = PVO.IPVO_CONTROLE and PVI.IPVI_DATAENTRADA >= @INICIO),0)
,TEMPOMEDIO = ISNULL((select avg(IPVO_TEMPO) FROM INT_PEDIDO_VENDA_OUT O WITH(NOLOCK) WHERE O.IPVO_DATAINTEGRACAO >= @INICIO AND IPVO_TEMPO IS NOT NULL),0)
,TEMPOESPERA = ISNULL((select avg(datediff(SS,PVI.IPVI_DATAENTRADA,PVO.IPVO_DATAINTEGRACAO)) FROM INT_PEDIDO_VENDA_IN PVI WITH(NOLOCK), INT_PEDIDO_VENDA_OUT PVO WITH(NOLOCK) WHERE PVI.IPVI_CONTROLE = PVO.IPVO_CONTROLE and PVO.IPVO_DATAINTEGRACAO >= @INICIO),0)
, ULTIMO =  ISNULL((SELECT MAX(IPVO_DATAINTEGRACAO) FROM INT_PEDIDO_VENDA_OUT O WITH (NOLOCK)),0)
, MAIS_ANTIGO = MIN(IPVI_DATAENTRADA)
from [dbo].[INT_PEDIDO_VENDA_IN] I (NOLOCK)
LEFT OUTER JOIN [dbo].[INT_PEDIDO_VENDA_OUT] O (NOLOCK) ON
	O.IPVO_CONTROLE = I.IPVI_CONTROLE 
WHERE 1 = 1
AND  I.IPVI_DATAENTRADA >= @INICIO
AND   O.IPVO_DATAINTEGRACAO IS NULL
UNION
select TIPO = 'DEVOLUCAO-TIT_PAG'
,ENFILEIRADOS = count(DISTINCT I.IDPI_CONTROLE)
,PROCESSADOS = ISNULL((select count(distinct IDPI_CONTROLE) FROM INT_DEV_TIT_PAG_IN PVI WITH(NOLOCK), INT_DEV_TIT_PAG_OUT PVO WITH(NOLOCK) WHERE PVI.IDPI_CONTROLE = PVO.IDPO_CONTROLE and PVI.IDPI_DATAENTRADA >= @INICIO),0)
,TEMPOMEDIO = NULL
,TEMPOESPERA = ISNULL((select avg(datediff(SS,PVI.IDPI_DATAENTRADA,PVO.IDPO_DATAINTEGRACAO)) FROM INT_DEV_TIT_PAG_IN PVI WITH(NOLOCK), INT_DEV_TIT_PAG_OUT PVO WITH(NOLOCK) WHERE PVI.IDPI_CONTROLE = PVO.IDPO_CONTROLE and PVO.IDPO_DATAINTEGRACAO >= @INICIO),0)
, ULTIMO =  ISNULL((SELECT MAX(IDPO_DATAINTEGRACAO) FROM INT_DEV_TIT_PAG_OUT O WITH (NOLOCK)),0)
, MAIS_ANTIGO = MIN(IDPI_DATAENTRADA)
from [dbo].[INT_DEV_TIT_PAG_IN] I (NOLOCK)
LEFT OUTER JOIN [dbo].[INT_DEV_TIT_PAG_OUT] O (NOLOCK) ON
	O.IDPO_CONTROLE = I.IDPI_CONTROLE 
WHERE 1 = 1
AND  I.IDPI_DATAENTRADA >= @INICIO
AND   O.IDPO_DATAINTEGRACAO IS NULL

) AS A
order by TIPO
/*

SELECT
	I.ITRI_SISTEMA
	, IIF(I.ITRI_MOVIMENTO IN (15,10,5),'INCLUSAO',IIF(I.ITRI_MOVIMENTO IN (16,11,20),'MOVIMENTO','OUTROS'))
	, EMPRESA = LEFT(I.ITRI_FILIAL,1)
	, QUANTIDADE = COUNT(DISTINCT I.ITRI_CONTROLE)
	, ANTIGO = min(I.ITRI_DATAENTRADA)
FROM INT_TIT_REC_IN I WITH (NOLOCK)
LEFT OUTER JOIN INT_TIT_REC_OUT O WITH (NOLOCK) ON
	O.ITRO_CONTROLE = I.ITRI_CONTROLE
WHERE 
NOT EXISTS (SELECT 1 FROM INT_TIT_REC_OUT X WITH (NOLOCK) WHERE X.ITRO_CONTROLE = I.ITRI_CONTROLE)
GROUP BY I.ITRI_SISTEMA, IIF(I.ITRI_MOVIMENTO IN (15,10,5),'INCLUSAO',IIF(I.ITRI_MOVIMENTO IN (16,11,20),'MOVIMENTO','OUTROS')), LEFT(I.ITRI_FILIAL,1)
order BY IIF(I.ITRI_MOVIMENTO IN (15,10,5),'INCLUSAO',IIF(I.ITRI_MOVIMENTO IN (16,11,20),'MOVIMENTO','OUTROS')), I.ITRI_SISTEMA, LEFT(I.ITRI_FILIAL,1)


SELECT I.ITRI_CONTROLE, I.*
FROM INT_TIT_REC_IN I WITH (NOLOCK)
LEFT OUTER JOIN INT_TIT_REC_OUT O WITH (NOLOCK) ON
	O.ITRO_CONTROLE = I.ITRI_CONTROLE
WHERE 
NOT EXISTS (SELECT 1 FROM INT_TIT_REC_OUT X WITH (NOLOCK) WHERE X.ITRO_CONTROLE = I.ITRI_CONTROLE)
AND I.ITRI_SISTEMA = 'TOTVS EDUCACIONAL' AND I.ITRI_MOVIMENTO IN (15,10,5) --and LEFT(I.ITRI_FILIAL,1) = '3'
order by I.ITRI_DATAENTRADA

select top 40 controle
from
(
SELECT top 100 percent itri.ITRI_CONTROLE controle
from INT_TIT_REC_IN itri (NOLOCK)
where itri.ITRI_QTD_REGISTRO = (select COUNT(*) from INT_TIT_REC_IN itri_qtd (NOLOCK) where itri_qtd.ITRI_CONTROLE = itri.ITRI_CONTROLE)
AND   NOT EXISTS (SELECT 1 FROM INT_TIT_REC_OUT O (NOLOCK) where O.ITRO_CONTROLE = itri.ITRI_CONTROLE)
AND   itri.ITRI_MOVIMENTO IN (15,10,5)
AND   ITRI.ITRI_SISTEMA IN  ('TOTVS EDUCACIONAL')
AND   ITRI.ITRI_FILIAL LIKE '3%'
AND   ITRI.FILA = 7
--AND ITRI_CONTROLE = 85470080
--and convert(varchar(10), ITRI_DATAENTRADA,103) = @data_mais_antiga
GROUP BY itri.ITRI_CONTROLE	
order by itri.itri_controle
) as t



SELECT COUNT(DISTINCT ICOI_CONTROLE) FROM INT_CONTABILIDADE_IN I WITH (NOLOCK) 
WHERE NOT EXISTS(SELECT 1 FROM INT_CONTABILIDADE_OUT O WITH (NOLOCK) WHERE O.ICOO_CONTROLE = I.ICOI_CONTROLE)
AND ICOI_SISTEMA = 'TOTVS EDUCACIONAL'
AND ICOI_FILIAL LIKE '2%'
AND FILA = 3

SELECT
	I.ITRI_SISTEMA
	, IIF(I.ITRI_MOVIMENTO IN (15,10,5),'INCLUSAO',IIF(I.ITRI_MOVIMENTO IN (16,11,20),'MOVIMENTO','OUTROS'))
	,I.FILA
	, EMPRESA = LEFT(I.ITRI_FILIAL,1)
	, QUANTIDADE = COUNT(DISTINCT I.ITRI_CONTROLE)
	, ANTIGO = min(I.ITRI_DATAENTRADA)
FROM INT_TIT_REC_IN I WITH (NOLOCK)
LEFT OUTER JOIN INT_TIT_REC_OUT O WITH (NOLOCK) ON
	O.ITRO_CONTROLE = I.ITRI_CONTROLE
WHERE 
LEFT(I.ITRI_FILIAL,1) = '3' AND I.ITRI_MOVIMENTO IN (15,10,5) AND
NOT EXISTS (SELECT 1 FROM INT_TIT_REC_OUT X WITH (NOLOCK) WHERE X.ITRO_CONTROLE = I.ITRI_CONTROLE)
GROUP BY I.ITRI_SISTEMA, IIF(I.ITRI_MOVIMENTO IN (15,10,5),'INCLUSAO',IIF(I.ITRI_MOVIMENTO IN (16,11,20),'MOVIMENTO','OUTROS')), LEFT(I.ITRI_FILIAL,1),I.FILA
order BY IIF(I.ITRI_MOVIMENTO IN (15,10,5),'INCLUSAO',IIF(I.ITRI_MOVIMENTO IN (16,11,20),'MOVIMENTO','OUTROS')), I.ITRI_SISTEMA, LEFT(I.ITRI_FILIAL,1),I.FILA



*/