---
name: billetera-mobile-dev
description: Desarrollar y mantener la app billeteraMobile (Flutter + Supabase + FastAPI) con ejecución guiada por el SRS y el backlog de módulos. Usar esta skill cuando se pidan cambios funcionales, técnicos o de documentación del proyecto, especialmente en reglas financieras y paridad iOS/Android.
---

# Billetera Mobile Dev

## Objetivo
Implementar cambios del proyecto usando como fuente de verdad el SRS y el plan de módulos, manteniendo paridad funcional en iOS y Android.

## Flujo de trabajo
1. Leer [SRS_app_finanzas.md](../../SRS_app_finanzas.md) y [modulos_y_tareas_app_finanzas.md](../../modulos_y_tareas_app_finanzas.md) para ubicar alcance y prioridad.
2. Identificar impacto por capa:
   - Flutter (`presentation/domain/data`)
   - FastAPI (`routers/services/schemas`)
   - Supabase (tablas, RLS, migraciones, soft delete)
3. Aplicar cambios mínimos y trazables respetando reglas financieras:
   - Egreso con tarjeta: aumentar deuda y no reducir activos.
   - Pago a tarjeta: reducir deuda y reducir activos.
   - Soft delete: evitar borrado físico en flujos funcionales.
4. Validar paridad iOS/Android para UX y capacidades nativas (biometría, notificaciones, compras in-app).
5. Actualizar documentación del repo cuando cambie alcance, reglas o tareas.

## Guías de decisión
- Priorizar componentes Flutter reutilizables y adaptar interacciones por plataforma cuando la UX nativa difiera.
- Ubicar cálculos críticos en backend o dominio para evitar inconsistencias entre pantallas.
- Validar RLS e integridad de datos antes de cerrar cualquier cambio de modelo o endpoint.
- Considerar impacto de release en iOS (TestFlight/App Store) y Android (Internal Testing/Play Console).

## Validación mínima
- Cambio de UI: revisar navegación, estados loading/empty/error y consistencia visual.
- Cambio de backend: probar caso exitoso y errores de permisos por usuario.
- Cambio de datos: validar migraciones, índices y filtros por `deleted_at`.
- Cambio multiplataforma: confirmar comportamiento equivalente en iOS y Android.

## Referencias
- Revisar [checklist-multiplataforma.md](./references/checklist-multiplataforma.md) antes de cerrar tareas que afecten mobile.
