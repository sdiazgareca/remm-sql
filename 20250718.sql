ALTER TABLE planes_traslados ADD COLUMN estado TINYINT(1) DEFAULT 1;
ALTER TABLE movil ADD UNIQUE (num);
ALTER TABLE movil ADD UNIQUE (patente);
ALTER TABLE movil ADD COLUMN activo BOOL DEFAULT TRUE;
ALTER TABLE personal ADD COLUMN activo BOOL DEFAULT TRUE;

CREATE INDEX idx_hora_llamado ON fichas(hora_llamado DESC);

CREATE INDEX idx_fichas_opt ON fichas(traslado, obser_man(10), hora_llamado DESC);
CREATE INDEX idx_convenio ON traslados(convenio);

DELIMITER $$

ALTER ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `afi` AS (
SELECT
  `afiliados`.`fecha_baja`     AS `fecha_baja`,
  `afiliados`.`nro_doc`        AS `nro_doc`,
  `afiliados`.`nombre1`        AS `nombre1`,
  `afiliados`.`nombre2`        AS `nombre2`,
  `afiliados`.`apellido`       AS `apellido`,
  `afiliados`.`sexo`           AS `sexo`,
  `obras_soc`.`nro_doc`        AS `cod_obras_soc`,
  `obras_soc`.`descripcion`    AS `des_obras_soc`,
  DATE_FORMAT(`afiliados`.`fecha_nac`,_utf8'%d-%m-%Y') AS `fecha_nac`,
  `afiliados`.`cod_parentesco` AS `cod_parentesco`,
  `afiliados`.`num_solici`     AS `num_solici`,
  `afiliados`.`cod_plan`       AS `cod_plan`,
  `afiliados`.`tipo_plan`      AS `tipo_plan`,
  `planes`.`desc_plan`         AS `desc_plan`,
  DATE_FORMAT(`afiliados`.`fecha_alta`,_utf8'%d-%m-%Y') AS `fecha_alta`,
  `afiliados`.`titular`        AS `titular`,
  DATE_FORMAT(`afiliados`.`fecha_act`,_utf8'%d-%m-%Y') AS `fecha_act`,
  DATE_FORMAT(`afiliados`.`fecha_ing`,_utf8'%d-%m-%Y') AS `fecha_ing`,
  `afiliados`.`pais`           AS `pais`,
  `afiliados`.`categoria`      AS `cod_categoria`,
  `categoria`.`descripcion`    AS `des_categoria`,
  `mot_baja`.`codigo`          AS `cod_mot_baja`,
  `mot_baja`.`descripcion`     AS `des_mot_baja`
FROM ((((`afiliados`
      LEFT JOIN `planes`
        ON (((`planes`.`cod_plan` = `afiliados`.`cod_plan`)
             AND (`planes`.`tipo_plan` = `afiliados`.`tipo_plan`))))
     LEFT JOIN `categoria`
       ON ((`categoria`.`categoria` = `afiliados`.`categoria`)))
    LEFT JOIN `mot_baja`
      ON ((`mot_baja`.`codigo` = `afiliados`.`cod_baja`)))
   LEFT JOIN `obras_soc`
     ON ((`obras_soc`.`nro_doc` = `afiliados`.`obra_numero`))))$$

DELIMITER ;

CREATE TABLE copago_tipo_pago (
  id INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  PRIMARY KEY (id)
)

-- Insertar valores iniciales
INSERT INTO copago_tipo_pago (id, nombre) VALUES
(1, 'EFECTIVO'),
(2, 'CHEQUE'),
(3, 'PENDIENTE'),
(4, 'CASOS ESPECIALES'),
(5, 'DESC. X PLANILLA'),
(6, 'MEDIMEL'),
(7, 'VIP PLATINIUM'),
(8, 'VIP DORADO'),
(9, 'ASISTENCIA INTEGRAL'),
(11, 'S/COPAGO');

ALTER TABLE planes 
ADD COLUMN prioridad_call TINYINT(1) NOT NULL DEFAULT 0 AFTER estado;

CREATE TABLE turnos (
  id INT(11) NOT NULL AUTO_INCREMENT,   -- PK autoincrementable
  numero INT(11) NOT NULL DEFAULT 0,
  medico INT(11) DEFAULT 0,
  paramedico INT(11) DEFAULT 0,
  conductor INT(11) DEFAULT 0,
  estado TINYINT(1) DEFAULT 0,
  fecha_inicio DATETIME NOT NULL,
  fecha_final DATETIME NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE movilasig
ADD COLUMN turno INT(11) NULL,
ADD CONSTRAINT fk_movilasig_turno
  FOREIGN KEY (turno) REFERENCES turnos(id);

ALTER TABLE turnos
MODIFY COLUMN fecha_inicio DATETIME NULL,
MODIFY COLUMN fecha_final DATETIME NULL;

CREATE INDEX idx_fechas ON fichas(hora_llamado);
CREATE INDEX idx_correlativo ON fichas(correlativo);
CREATE INDEX idx_rut_correlativo ON sintomas_reg(rut, correlativo);
CREATE INDEX idx_protocolo ON copago(protocolo);
CREATE INDEX idx_cod ON traslados(cod);

-- 1. Crear índice en fichas para la columna correlativo
ALTER TABLE fichas
ADD INDEX idx_fichas_correlativo (correlativo);

-- 2. Crear índice en sintomas_reg para la columna correlativo
ALTER TABLE sintomas_reg
ADD INDEX idx_sintomas_correlativo (correlativo);

-- 3. Agregar la foreign key
ALTER TABLE sintomas_reg
ADD CONSTRAINT fk_sintomas_fichas
FOREIGN KEY (correlativo)
REFERENCES fichas(correlativo)