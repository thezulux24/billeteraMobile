# SRS — App Finanzas Móvil (Flutter iOS/Android) con Supabase + FastAPI

**Versión:** 1.0  
**Fecha:** 2026-02-25  
**Plataformas:** iOS + Android (paridad funcional en MVP)  
**Frontend:** Flutter  
**Backend:** FastAPI  
**BaaS:** Supabase (Auth + Postgres + Storage)

---

## 1. Introducción

### 1.1 Propósito
Este documento define los requisitos funcionales y no funcionales de una aplicación móvil de finanzas personales que permitirá gestionar activos, tarjetas de crédito, deudas, presupuestos, amortizaciones y un asistente IA financiero.

### 1.2 Alcance
La aplicación permitirá:

- Registro de efectivo y cuentas bancarias.
- Registro de tarjetas de crédito (alias, red, últimos 4 dígitos).
- Registro de ingresos y egresos con categorías.
- Manejo de deuda de tarjetas (sin afectar activos hasta pago).
- Presupuestos por categoría con alertas.
- Dashboard con analítica financiera.
- Tablas de amortización.
- Asistente IA como asesor financiero.
- Soft delete (eliminación lógica).
- Modo Premium con funcionalidades avanzadas.

---

## 2. Descripción General

### 2.1 Arquitectura

- Flutter con diseño adaptativo para iOS y Android (paridad funcional)
- Supabase (Auth + PostgreSQL + RLS)
- FastAPI (lógica de negocio, agregaciones, IA, exportaciones)
- Integración API IA (ej. Gemini u otra opción gratuita)

### 2.2 Usuarios
Usuario individual que gestiona sus finanzas personales.

### 2.3 Restricciones
- No se integra inicialmente con Open Banking.
- El usuario ingresa manualmente sus datos financieros.

---

## 3. Requisitos Funcionales

### 3.1 Autenticación
- Registro e inicio de sesión con Supabase Auth.
- Recuperación de contraseña.
- Logout seguro.

### 3.2 Gestión de Activos
- Crear/editar efectivo.
- Crear/editar cuentas bancarias.
- Transferencias internas (opcional v1.1).
- Visualización de saldo actual.

### 3.3 Tarjetas de Crédito
- Registrar tarjeta (alias, red, últimos 4).
- Egresos con tarjeta aumentan deuda.
- Pago a tarjeta reduce activos y deuda.

### 3.4 Transacciones
- Registrar ingresos.
- Registrar egresos (efectivo, cuenta o tarjeta).
- Categoría obligatoria para egresos.
- Filtros por fecha, categoría y fuente.
- Soft delete de transacciones.

### 3.5 Categorías
- Categorías base predefinidas.
- CRUD de categorías personalizadas.

### 3.6 Presupuestos
- Presupuesto mensual por categoría.
- Alertas al 80% y 100%.
- Visualización de progreso.

### 3.7 Dashboard
Debe incluir:

- Total activos (efectivo + cuentas).
- Total deuda tarjetas.
- Balance neto.
- Resumen mensual ingresos/egresos.
- Top categorías de gasto.
- Comparación mes anterior.
- Insights automáticos.

### 3.8 Amortización
- Crear plan (principal, tasa, plazo).
- Generar tabla (método francés mínimo).
- Marcar cuotas como pagadas.
- Crear transacción automática al pagar cuota.

### 3.9 Asistente IA
- Chat contextual.
- Respuestas basadas en datos agregados.
- Preguntas rápidas predefinidas.
- Control de privacidad (modo agregados o completo).

### 3.10 Premium
Funciones sugeridas:

- Exportación CSV/PDF.
- Dashboards avanzados.
- IA avanzada.
- Presupuestos ilimitados.
- Amortización avanzada.
- Reglas automáticas de categorización.

---

## 4. Requisitos No Funcionales

### 4.1 Diseño y Estética (CRÍTICO)
La aplicación debe ser:

- Extremadamente estética.
- Inspirada en patrones nativos iOS (Human Interface) y Android (Material 3), con identidad visual unificada.
- Estilo “Liquid Glass”.
- Transparencias, blur, sombras suaves.
- Animaciones fluidas (60fps objetivo).
- Diseño coherente y premium.

### 4.5 Compatibilidad Multiplataforma
- Misma cobertura funcional en iOS y Android para todos los flujos del MVP.
- Validación de UX y comportamiento en ambas plataformas antes de cada release.
- Integraciones nativas (biometría, notificaciones, compras in-app) implementadas y probadas en iOS y Android.

### 4.2 Seguridad
- Row Level Security (RLS) por usuario.
- HTTPS obligatorio.
- Minimización de datos enviados a IA.
- Soft delete implementado.

### 4.3 Rendimiento
- Dashboard < 2 segundos.
- Operaciones CRUD rápidas.
- UI fluida sin bloqueos.

### 4.4 Integridad Financiera
- Reglas estrictas para deuda de tarjeta.
- Recalculo automático tras eliminación o edición.

---

## 5. Modelo de Datos (Resumen)

Tablas principales:

- profiles
- cash_wallets
- bank_accounts
- credit_cards
- categories
- transactions
- budgets
- budget_alerts
- amortization_plans
- amortization_schedule
- ai_chat_sessions
- ai_chat_messages

Todas con:
- id (uuid)
- user_id
- created_at
- updated_at
- deleted_at (soft delete)

---

## 6. Reglas de Negocio Clave

1. Egreso con tarjeta no reduce activos.
2. Pago a tarjeta reduce activos y deuda.
3. Soft delete no elimina físicamente datos.
4. Presupuestos se calculan por periodo mensual.

---

## 7. Fuera de Alcance (v1)

- Integración bancaria automática.
- Inversiones complejas.
- OCR automático de facturas.

---

## 8. Roadmap Sugerido

v1:
- Auth
- Activos
- Tarjetas
- Transacciones
- Presupuestos
- Dashboard básico

v1.1:
- Amortización
- IA básica

v2:
- Premium completo
- Automatizaciones
- IA avanzada

---
