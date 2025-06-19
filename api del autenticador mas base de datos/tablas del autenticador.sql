--create database DBAutenticador
go
create table cat_cuentas_autenticador_totp(
	cat_codigo int identity(1,1) not null primary key,
	cat_codper int not null,
	cat_cuenta varchar(255) not null,
	cat_clave varchar(255) not null
);
insert into cat_cuentas_autenticador_totp (cat_codper,cat_cuenta,cat_clave)values(206251,'mail.edu.sv:ever@mail.edu.sv','nb5kkdzt7lqvc77z')

create table usr_usuarios(
	usr_codigo int not null primary key,
	usr_usuario varchar(225) not null,
	usr_password varchar(225) not null,
)




insert into usr_usuarios (usr_codigo,usr_usuario,usr_password)values(206251,'admin','admin')

select * from cat_cuentas_autenticador_totp
