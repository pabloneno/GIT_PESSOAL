	   SELECT BD5_CODOPE + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG+BD5_DIGITO AS MAT,BD5_NOMUSR, SUM(BD5_VLRPAG) AS DESPESA
	   FROM BD5020
	   WHERE D_E_L_E_T_ = ''
	   AND BD5_FASE = '4'
	   AND BD5_SITUAC = '1'
	   --AND BD5_ANOPAG = '2022'
	   AND BD5_VLRPAG > 0
	  -- AND BD5_CODOPE + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG = '0001000200308700'
	  --AND BD5_DATPRO >= '20210801'
	 GROUP BY BD5_CODOPE + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG+BD5_DIGITO,BD5_NOMUSR
	 ORDER BY DESPESA DESC

	 	   SELECT BD5_CODOPE + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG+BD5_DIGITO AS MAT,BD5_NOMUSR, SUM(BD5_VLRPAG) AS DESPESA
	   FROM BD5020
	   WHERE D_E_L_E_T_ = ''
	   AND BD5_FASE = '4'
	   AND BD5_SITUAC = '1'
	   --AND BD5_ANOPAG = '2022'
	   AND BD5_VLRPAG > 0
	   AND BD5_CODOPE + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG = '0001000200308700'
	  --AND BD5_DATPRO >= '20210801'
	 GROUP BY BD5_CODOPE + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG+BD5_DIGITO,BD5_NOMUSR
	 ORDER BY DESPESA DESC

	 	   SELECT BD5_CODOPE + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG+BD5_DIGITO AS MAT,BD5_NOMUSR,*
		   FROM BD5020
	   WHERE D_E_L_E_T_ = ''
	   AND BD5_FASE = '4'
	   AND BD5_SITUAC = '1'
	   --AND BD5_ANOPAG = '2022'
	   AND BD5_VLRPAG > 0
	  AND BD5_CODOPE + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG+BD5_DIGITO = '00010001014181005'
	  --AND BD5_DATPRO >= '20210801'
	

