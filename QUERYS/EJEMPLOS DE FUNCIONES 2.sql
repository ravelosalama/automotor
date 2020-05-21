declare @valueint int
declare @pos int
declare @zeros varchar(6)
set @zeros='000000'



select @valueint= ValueInt from SACORRELSIS where Fieldname='prxreteniva'
set @pos=6-LEN(@valueint)
select @valueint, LEN(str(@valueint)), SUBSTRING(@zeros,1,@pos), @pos, STR(@valueint), RIGHT(@valueint,5), SPACE(@valueint),SUBSTRING(@zeros,1,@pos)+ltrim(str(@valueint))
SELECT CodProv, NroUnico, NroRegi, FechaE, FechaV, CodSucu, CodEsta, CodUsua, CodOper, NroCtrol, FromTran, TipoCxP, Moneda, Factor, MontoMEx, 
                      SaldoMEx, [Document], Notas1, Notas2, Notas3, Notas4, Notas5, Notas6, Notas7, Notas8, Notas9, Notas10, Monto, MontoNeto, MtoTax, RetenIVA, 
                      OrgTax, Saldo, SaldoAct, EsLibroI, BaseImpo, CancelI, CancelA, CancelE, CancelC, CancelT, CancelG, EsUnPago, EsReten, DetalChq, AfectaCom, 
                       SaldoOrg, FechaI, NumeroN, Descrip, ID3, TExento, FechaR, FechaT, NumeroDN, NumeroD, NroOPago, CancelD, EsRetenIVA
FROM         SAACXP
WHERE     (CodProv = 'V10115144')



