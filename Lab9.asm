;Universidad del Valle de Guatemala
; Pedro Pablo Guzmán Mayen - 22111
; Descripcion;: Programa que analiza el año fiscal de una empresa
; 24/05/2023

.386
.model flat, stdcall, C
.stack 4096


.data
	;Definir los nits
	nit1 BYTE "123456789",0
	nit2 BYTE "987654321",0
	nit3 BYTE "246813579",0
	nit4 BYTE "314159265",0
	nit5 BYTE "777777777",0
	nit6 BYTE "999999999",0
	nit7 BYTE "555555555",0
	nit8 BYTE "432109876",0
	nit9 BYTE "654321098",0
	nit10 BYTE "888888888",0
	nit11 BYTE "222222222",0
	nit12 BYTE "777777777",0

	;Definir los meses
	mes1 BYTE "Junio 2022",0
	mes2 BYTE "Julio 2022",0
	mes3 BYTE "Agosto 2022",0
	mes4 BYTE "Septiembre 2022",0
	mes5 BYTE "Octubre 2022",0
	mes6 BYTE "Noviembre 2022",0
	mes7 BYTE "Diciembre 2022",0
	mes8 BYTE "Enero 2023",0
	mes9 BYTE "Febrero 2023",0
	mes10 BYTE "Marzo 2023",0
	mes11 BYTE "Abril 2023",0
	mes12 BYTE "Mayo 2022",0


	;Definir los arrays
	nits DWORD nit1, nit2, nit3, nit4, nit5, nit6, nit7, nit8, nit9, nit10, nit11, nit12 ;Guarda los nits de los clientes
	meses DWORD mes1, mes2, mes3, mes4, mes5, mes6, mes7, mes8, mes9, mes10, mes11, mes12 ;Guarda los meses
	montos DWORD 12 DUP (0) ;Guarda los montos de todos los clientes
	iva_clientes DWORD 12 DUP (0) ;Guarda el iva de cada cliente

	;Definir las variables para hacer calculos

	comparador DWORD 150000
	iva_porcentaje DWORD 5
	iva_divisor DWORD 100
	montoTotal DWORD 0

	;Variables para imprimir
	msg BYTE "Ingrese el monto del mes: '%s' ",0Ah, 0
	msg1 BYTE "Este es el resumen de los datos: ",0Ah,0
	msg2 BYTE "Mes: '%s' ",0Ah,0
	msg4 BYTE "Nit: '%s' ", 0Ah,0
	msg5 BYTE "Monto: '%d' ",0Ah,0
	msg6 BYTE "Iva: '%d'", 0Ah, 0
	warning1 BYTE "Puede seguir como pequeno contribuyente",0Ah,0
	warning2 BYTE "Debe cambiar su regimen tributario a IVA general"
	espaciador BYTE "----",0Ah,0
	fmt BYTE "%d",0

	
	
.code
main proc
	; Declaración de librerias y funciones
	includelib libucrt.lib
	includelib legacy_stdio_definitions.lib
	includelib libcmt.lib
	includelib libvcruntime.lib

	extrn printf:near
	extrn scanf:near
	extrn exit:near

	mov esi, 0 ;Definir el apuntador para manejar el array
	mov ebx, sizeof meses ;Guardar el tamaño del array, esto servirá para recorrerlo

	;En esta etiqueta pedimos los datos de cada mes
	label1: 
		mov ecx, meses[esi] ;Mover el elemento del array al registro
		push ecx
		push offset msg
		call printf ;Imprimir el mes
		add esp, 8 ;Limpiar el stack

		lea eax, montos[esi] ;Obtener la dirección de donde queremos guardar el dato ingresado por el usuario
		push eax
		push offset fmt ;Incluir el formato
		call scanf ;Llamar a scanf
		add esp, 8 ;Limpiar el stack de nuevo

		add esi, 4 ;Sumarle 4 a esi para que en la próxima iteración se trabaje con el siguiente elemento del array
		sub ebx, 4 ;Restarle 4 a ebx, esto nos indicará cuantas iteraciones más debemos hacer
		cmp ebx,0 ;Comparar ebx con 0
		jne label1 ;Si no es igual, volver a label1

		;Reinicar los registros
	mov esi, 0
	mov ebx, sizeof montos
	mov eax, 0
	mov ecx, 0
	; En esta etiqueta nos encargaremos de calcular los ivas y guardalos en el array de ivas
	label2: 
		mov eax, montos[esi] ;Usar eax para operar
		imul eax, iva_porcentaje ;Multiplicar por 5
		cdq
		idiv iva_divisor ;Dividir dentro de 100
		mov iva_clientes[esi], eax ;Guardar el array de ivas
		;Modificar los registros para saber el siguiente elemento del array y las iteraciones 
		add esi, 4 
		sub ebx, 4
		cmp ebx, 0
		jne label2

	;Resetear todo de nuevo
	mov esi, 0
	mov eax, 0
	mov ebx, 12
	mov ecx, 0

	;Finalmente, usar el array de montos para calcular el monto total

	label3:
		 mov eax, montos[esi] ;Mover a eax el valor de montos que quermos
		 add montoTotal, eax ;Añadir el valor a montoTotal
		 ;Operaciones para que el ciclo funcione
		 add esi, 4
		 sub ebx, 1
		 cmp ebx, 0
		 jne label3

	;Limpiar todo de nuevo
	mov eax, 0
	mov esi,0
	mov ebx, 12


	push offset msg1
	call printf
	add esp, 4

	;Ahora por fin podemos mostrar los datos

	label4:
		mov eax, meses[esi] ;Mover el array de meses a eax
		push eax
		push offset msg2 ;Meter el formato y el valor al stack
		call printf ;Imprimir
		add esp,8

		;Hacer el mismo proceso, solamente que con los distintos arrays
		mov ebx, nits[esi]
		push ebx
		push offset msg4
		call printf
		add esp,8

		mov ecx, montos[esi]
		push ecx
		push offset msg5
		call printf
		add esp,8

		mov edx, iva_clientes[esi]
		push edx
		push offset msg6
		call printf
		add esp,8

		push offset espaciador ;Imprimir un espacio en blanco
		call printf
	

		add esi, 4
		sub ebx, 1
		cmp ebx, 0
		jne label4

	mov ebx, montoTotal

	.IF ebx > 15000
		push offset warning2
		call printf
		add esp, 4
	.ELSE
		 push offset warning1
		 call printf
		 add esp,4
	.ENDIF



main endp



end