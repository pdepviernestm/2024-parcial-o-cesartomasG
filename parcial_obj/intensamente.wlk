class Persona{
    //atributos
    const nombre
    var edad
    var emocionElevada = 100
    var emociones = #{}
    
    //mensajes de consulta
    method esAdolescente() = edad>=12 && edad<=19

    method estaPorExplotar(){
        //busca en la lista una emocion que no pueda liberarse, si no la encuentra devuelve 0
        const condicion = emociones.findOrDefault({emocion=>!emocion.puedeLiberarse(emocionElevada)}, 0)
        
        //si la condicon es igual a 0, todas las emociones pueden liberarse y esta por explotar
        return condicion==0
    }
        
    //mensajes de modificacion
    method otorgarEmocion(emocion) {
      emociones.add(emocion)
    }
    method modificarLimiteIntensidad(nuevoValor) {
      emocionElevada=nuevoValor
    }

    method aceptarEvento(descripcion, impactoEvento) {
        emociones.forEach({emocion=>emocion.analizarSituacion(emocionElevada, descripcion, impactoEvento)})
    }
}


class Evento{
    var descripcion
    var impacto

    method ocurrir(persona) {
        persona.aceptarEvento(descripcion, impacto)
    }

    method ocurrirColectivamente(personas) {
        personas.forEach({persona => self.ocurrir(persona)})
    }
}


class Emocion {
    //atributos
    var intensidad
    var cantidadEventosVividos = 0

    //mensajes de consulta
    method informarEventosVividos() = cantidadEventosVividos

    method informarIntensidad() = intensidad
    
    method puedeLiberarse(limiteIntensidad) {
        return intensidad>=limiteIntensidad && intensidad<cantidadEventosVividos
    }

    //mensajes de modificacion
    method liberarEmocion(descripcion, impactoEvento) {
      intensidad-=impactoEvento
    }

    method analizarSituacion(limiteIntensidad, descripcion, impactoEvento) {
        if(self.puedeLiberarse(limiteIntensidad)){
            self.liberarEmocion(descripcion, impactoEvento)
        }
        cantidadEventosVividos+=1
    }

}


class Furia inherits Emocion {
    var palabrotas = #{}
    
    //mensajes de consulta
    override method puedeLiberarse(limiteIntensidad) {
        //busca en la lista una palabra con 7 letras, si no la encuetra devuelve 0
        const condicion = palabrotas.findOrDefault({palabrota=>palabrota.length()>=7}, 0)
    
        return condicion!=0 && intensidad>=limiteIntensidad
    }

    //mensajes de modificacion
    method aprenderPalabrota(palabrota) {
        palabrotas.add(palabrota)
    }

    override method liberarEmocion(descripcion, impactoEvento) {
        //aca no me acordaba como obtener el primer elemento pero la logica creo que esta ok
        const element = palabrotas.get(0)
        palabrotas.remove(element)
        intensidad-=impactoEvento
    }
  
}

class Alegria inherits Emocion {
    //mensajes de consulta
    override method puedeLiberarse(limiteIntensidad) {
        return intensidad>=limiteIntensidad && cantidadEventosVividos.even()
    }



    //mensajes de modificacion
    override method liberarEmocion(descripcion, impactoEvento) {
        intensidad-=impactoEvento
        if(intensidad<0){
            intensidad = intensidad*-1
        }
    }
}

class Tristeza inherits Emocion {
    var causa = "melancolia"

    //mensajes de consulta
    override method puedeLiberarse(limiteIntensidad) {
        return intensidad>=limiteIntensidad && causa!="melancolia"
    }

    //mensajes de modificacion
    override method liberarEmocion(descripcion, impactoEvento) {
      causa=descripcion
      intensidad-=impactoEvento
    }
  
}

//desagrado y temor no fue necesario realizarlas ya que utilizan solo lo gestionado en la clase principal

// class Desagrado inherits Emocion 

// class Temor inherits Emocion 



//INTENSAMENTE 2
/*En este caso, la ansiedad solo va a poder liberarse cada 5 eventos (el resto de la cantidad de eventos vividos / 5 == 0)
cuando su intensidad sea >= al limite establecido, cuando eso suceda se libera la emocion y ocurre un "momento ansioso"
cuando hayan transcurrido al menos 3 momentos ansiosos, su intensidad sera de 100 puntos

En este caso se utiliza HERENCIA de la clase emocion para conocer la intesidad, la cantidadEventosVividos
y para gestionar el analisis de la situacion (lo que gestiona la liberacion de las emociones)

Por otro lado, se aplica POLIMORFISMO cuando se reescriben los metodos puedeLiberarse y liberarEmocion, los cuales son
los encargados de aplicar los cambios al liberar emociones o corroborar que dichas emociones estan aptas para liberarse
En este caso se sobreescriben para sumarles funcionalidad
*/
class Ansiedad inherits Emocion {
    var momentosAnsiosos = 0

    //mensajes de consulta
    override method puedeLiberarse(limiteIntensidad) {
        return intensidad>=limiteIntensidad && (cantidadEventosVividos%5==0)
    }

    method desestabilizado() = momentosAnsiosos>3

    //mensajes de modificacion
    override method liberarEmocion(descripcion, impactoEvento) {
      momentosAnsiosos+=1
      intensidad-=impactoEvento
      if(self.desestabilizado()){
        intensidad=100
        momentosAnsiosos=0
      }
    }
}