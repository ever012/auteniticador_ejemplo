﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace ApiAuth.Modelos;

public partial class usr_usuario
{
    [Key]
    public int usr_codigo { get; set; }

    [Required]
    [Column("usr_usuario")]
    [StringLength(225)]
    [Unicode(false)]
    public string usr_usuario1 { get; set; }

    [Required]
    [StringLength(225)]
    [Unicode(false)]
    public string usr_password { get; set; }
}