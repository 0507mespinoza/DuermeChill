package com.intermodular.duermechill.dto;

import java.util.List;

public class RelojIngestarRequest {

    private String nombre;
    private String fecha;
    private List<PulsacionDto> pulsaciones;
    private List<FaseSuenoDto> fasesSueno;

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getFecha() { return fecha; }
    public void setFecha(String fecha) { this.fecha = fecha; }

    public List<PulsacionDto> getPulsaciones() { return pulsaciones; }
    public void setPulsaciones(List<PulsacionDto> pulsaciones) { this.pulsaciones = pulsaciones; }

    public List<FaseSuenoDto> getFasesSueno() { return fasesSueno; }
    public void setFasesSueno(List<FaseSuenoDto> fasesSueno) { this.fasesSueno = fasesSueno; }

    public static class PulsacionDto {
        private int minuto;
        private int valor;

        public int getMinuto() { return minuto; }
        public void setMinuto(int minuto) { this.minuto = minuto; }

        public int getValor() { return valor; }
        public void setValor(int valor) { this.valor = valor; }
    }

    public static class FaseSuenoDto {
        private String fase;
        private double horas;

        public String getFase() { return fase; }
        public void setFase(String fase) { this.fase = fase; }

        public double getHoras() { return horas; }
        public void setHoras(double horas) { this.horas = horas; }
    }
}
