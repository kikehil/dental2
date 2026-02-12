# 🧪 Guía de Validación - Mejoras Implementadas

Esta guía te ayudará a validar las nuevas funcionalidades implementadas.

## 📋 Preparación

### 1. Asegúrate de que el servidor esté corriendo

```powershell
npm run dev
```

El servidor debe estar en: **http://localhost:3005**

### 2. Inicia sesión

Usa un usuario administrador:
- **Email:** `admin@clinica.com`
- **Contraseña:** `admin123`

---

## ✅ VALIDACIÓN 1: Préstamos con Selección de Fuente de Dinero

### Paso 1: Verificar saldos disponibles

1. Ve a **Gastos** → **Préstamos al Personal**
2. Haz clic en **"Nuevo Préstamo"**
3. **VERIFICA:** Debe aparecer un selector **"Fuente de Dinero"** con opciones:
   - EFECTIVO
   - Azteca
   - BBVA
   - Mercado Pago

### Paso 2: Verificar que se muestran los saldos disponibles

1. Selecciona una fuente (ej: **EFECTIVO**)
2. **VERIFICA:** Debe aparecer un mensaje mostrando el saldo disponible:
   ```
   Saldo disponible en EFECTIVO: $X,XXX.XX
   ```
3. Cambia a otra fuente (ej: **Azteca**)
4. **VERIFICA:** El saldo debe cambiar según la fuente seleccionada

### Paso 3: Validar que previene préstamos mayores al saldo

1. Selecciona una fuente con saldo conocido (ej: **EFECTIVO** con $100)
2. Ingresa un monto **MAYOR** al saldo disponible (ej: $500)
3. **VERIFICA:** Debe aparecer un mensaje de error en rojo:
   ```
   El monto ($500.00) excede el saldo disponible ($100.00) en EFECTIVO
   ```
4. **VERIFICA:** El botón "Guardar" debe estar deshabilitado o mostrar error

### Paso 4: Crear un préstamo válido

1. Selecciona un **Doctor** (ej: Dr. Juan Pérez)
2. Selecciona un **Concepto** (ej: Adelanto de sueldo)
3. Selecciona una **Fuente de Dinero** (ej: EFECTIVO)
4. Ingresa un **Monto** menor o igual al saldo disponible (ej: $50)
5. Agrega **Notas** (opcional)
6. Haz clic en **"Guardar"**

**VERIFICA:**
- ✅ Debe aparecer mensaje de éxito: "Préstamo registrado exitosamente"
- ✅ El préstamo debe aparecer en la lista
- ✅ El saldo de la fuente seleccionada debe haberse reducido

### Paso 5: Verificar que se creó el gasto

1. Ve a **Gastos** → **Gastos Generales**
2. **VERIFICA:** Debe aparecer un nuevo gasto con:
   - **Motivo:** "Préstamo a Dr. [Nombre] [Apellido] - [Concepto]"
   - **Monto:** El monto del préstamo
   - **Método de Pago:** El método correspondiente a la fuente seleccionada
   - **Banco:** El banco (si aplica)

### Paso 6: Verificar que se descontó del corte de caja

1. Ve a **POS** (si tienes acceso)
2. Revisa el **Corte de Caja** del día
3. **VERIFICA:** El saldo final de la fuente utilizada debe haberse reducido

### Paso 7: Probar con diferentes fuentes

Repite los pasos 4-6 con:
- ✅ **EFECTIVO**
- ✅ **Azteca** (debe usar transferencia)
- ✅ **BBVA** (debe usar transferencia)
- ✅ **Mercado Pago** (debe usar transferencia)

---

## ✅ VALIDACIÓN 2: Eliminación Permanente de Doctores

### Paso 1: Verificar botones en la lista de doctores

1. Ve a **Doctores**
2. **VERIFICA:** Cada doctor debe tener **3 botones**:
   - ✏️ **Editar** (azul)
   - 🚫 **Desactivar** (amarillo) - icono de ban
   - 🗑️ **Eliminar Permanentemente** (rojo) - icono de basura

### Paso 2: Probar desactivación (soft delete)

1. Haz clic en el botón **🚫 Desactivar** de un doctor
2. **VERIFICA:** Debe aparecer confirmación: "¿Está seguro de desactivar este doctor?"
3. Confirma
4. **VERIFICA:**
   - ✅ El doctor sigue apareciendo en la lista
   - ✅ Su estado cambia a **"Inactivo"** (badge rojo)
   - ✅ El doctor NO aparece en listas de doctores activos

### Paso 3: Probar eliminación permanente (hard delete)

**⚠️ IMPORTANTE:** Usa un doctor de prueba que no tenga datos importantes

1. Haz clic en el botón **🗑️ Eliminar Permanentemente** de un doctor
2. **VERIFICA:** Debe aparecer confirmación:
   ```
   ¿Está SEGURO de eliminar PERMANENTEMENTE este doctor? 
   Esta acción NO se puede deshacer.
   ```
3. Confirma
4. **VERIFICA:**
   - ✅ El doctor **NO** debe aparecer en la lista
   - ✅ El doctor debe estar eliminado de la base de datos

### Paso 4: Verificar en la base de datos (opcional)

```powershell
npx prisma studio
```

1. Abre Prisma Studio
2. Ve a la tabla **doctores**
3. **VERIFICA:** El doctor eliminado permanentemente NO debe existir

---

## ✅ VALIDACIÓN 3: Eliminación Permanente de Pacientes

### Paso 1: Verificar botones en la lista de pacientes

1. Ve a **Pacientes**
2. **VERIFICA:** Cada paciente debe tener **4 botones**:
   - 👁️ **Ver** (azul)
   - ✏️ **Editar** (gris)
   - 🚫 **Desactivar** (amarillo) - icono de ban
   - 🗑️ **Eliminar Permanentemente** (rojo) - icono de basura

### Paso 2: Probar desactivación (soft delete)

1. Haz clic en el botón **🚫 Desactivar** de un paciente
2. **VERIFICA:** Debe aparecer confirmación: "¿Está seguro de desactivar este paciente?"
3. Confirma
4. **VERIFICA:**
   - ✅ El paciente sigue apareciendo en la lista
   - ✅ El paciente NO aparece en búsquedas de pacientes activos

### Paso 3: Probar eliminación permanente (hard delete)

**⚠️ IMPORTANTE:** Usa un paciente de prueba que no tenga datos importantes

1. Haz clic en el botón **🗑️ Eliminar Permanentemente** de un paciente
2. **VERIFICA:** Debe aparecer confirmación:
   ```
   ¿Está SEGURO de eliminar PERMANENTEMENTE este paciente? 
   Esta acción NO se puede deshacer.
   ```
3. Confirma
4. **VERIFICA:**
   - ✅ El paciente **NO** debe aparecer en la lista
   - ✅ El paciente debe estar eliminado de la base de datos

### Paso 4: Verificar en la base de datos (opcional)

```powershell
npx prisma studio
```

1. Abre Prisma Studio
2. Ve a la tabla **pacientes**
3. **VERIFICA:** El paciente eliminado permanentemente NO debe existir

---

## 🐛 Solución de Problemas

### Problema: No aparecen los saldos disponibles

**Solución:**
1. Verifica que hay un corte de caja del día actual
2. Verifica que hay ventas o saldo inicial registrado
3. Abre la consola del navegador (F12) y revisa errores
4. Verifica que la ruta `/gastos/prestamos/saldos` funciona:
   ```
   http://localhost:3005/gastos/prestamos/saldos
   ```

### Problema: El préstamo no descuenta del saldo

**Solución:**
1. Verifica que existe un corte de caja del día actual
2. Revisa la consola del servidor para errores
3. Verifica que el método de pago y banco se están enviando correctamente

### Problema: No aparecen los botones de eliminar

**Solución:**
1. Verifica que estás logueado como administrador
2. Recarga la página (Ctrl+F5)
3. Verifica que los archivos de vista se actualizaron correctamente

### Problema: Error al eliminar permanentemente

**Solución:**
1. Verifica que el doctor/paciente no tiene relaciones importantes (citas, ventas, etc.)
2. Revisa la consola del servidor para el error específico
3. Algunas relaciones pueden tener `onDelete: Cascade` y eliminar datos relacionados

---

## 📊 Checklist de Validación Completa

### Préstamos
- [ ] Aparece selector de fuente de dinero
- [ ] Se muestran saldos disponibles en tiempo real
- [ ] Previene préstamos mayores al saldo disponible
- [ ] Permite crear préstamos válidos
- [ ] Crea registro en gastos automáticamente
- [ ] Descuenta del saldo del corte de caja
- [ ] Funciona con EFECTIVO
- [ ] Funciona con Azteca
- [ ] Funciona con BBVA
- [ ] Funciona con Mercado Pago

### Doctores
- [ ] Aparecen botones de desactivar y eliminar
- [ ] Desactivación funciona (soft delete)
- [ ] Eliminación permanente funciona (hard delete)
- [ ] Confirmaciones aparecen correctamente

### Pacientes
- [ ] Aparecen botones de desactivar y eliminar
- [ ] Desactivación funciona (soft delete)
- [ ] Eliminación permanente funciona (hard delete)
- [ ] Confirmaciones aparecen correctamente

---

## 🎯 Pruebas Adicionales Recomendadas

### Prueba de Integración: Préstamo → Gasto → Corte

1. Crea un préstamo de $100 desde EFECTIVO
2. Verifica que aparece en Gastos Generales
3. Verifica que el saldo de EFECTIVO se redujo en $100
4. Verifica en el Corte de Caja que se refleja el cambio

### Prueba de Validación: Múltiples préstamos

1. Crea varios préstamos desde la misma fuente
2. Verifica que cada uno descuenta correctamente
3. Verifica que el saldo disponible se actualiza correctamente

### Prueba de Seguridad: Eliminación

1. Intenta eliminar un doctor con citas activas
2. Intenta eliminar un paciente con tratamientos pendientes
3. Verifica que el sistema maneja correctamente las relaciones

---

## 📝 Notas Finales

- **Saldos:** Los saldos se calculan en tiempo real basándose en:
  - Saldo inicial del día
  - Ventas del día
  - Gastos del día (incluyendo préstamos anteriores)

- **Eliminación:** La eliminación permanente es **IRREVERSIBLE**. Usa con precaución.

- **Gastos:** Los préstamos se registran automáticamente como gastos para mantener la trazabilidad.

---

¿Todo funcionó correctamente? ¡Excelente! 🎉

Si encuentras algún problema, revisa la sección de "Solución de Problemas" o verifica los logs del servidor.


