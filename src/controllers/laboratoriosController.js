const prisma = require('../config/database');

// Listar laboratorios
const index = async (req, res) => {
  try {
    const { search } = req.query;
    
    let where = { activo: true };
    if (search) {
      where.OR = [
        { nombre: { contains: search } },
        { contacto: { contains: search } },
        { telefono: { contains: search } },
      ];
    }

    const laboratorios = await prisma.laboratorio.findMany({
      where,
      orderBy: { createdAt: 'desc' },
    });

    res.render('laboratorios/index', {
      title: 'Laboratorios',
      laboratorios,
      search: search || '',
    });
  } catch (error) {
    console.error('Error al listar laboratorios:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar laboratorios', error });
  }
};

// Mostrar formulario de crear
const create = async (req, res) => {
  res.render('laboratorios/crear', {
    title: 'Nuevo Laboratorio',
    laboratorio: null,
    error: null,
  });
};

// Guardar nuevo laboratorio
const store = async (req, res) => {
  try {
    const { nombre, contacto, telefono } = req.body;

    if (!nombre || nombre.trim() === '') {
      return res.render('laboratorios/crear', {
        title: 'Nuevo Laboratorio',
        laboratorio: req.body,
        error: 'El nombre es requerido',
      });
    }

    const laboratorio = await prisma.laboratorio.create({
      data: {
        nombre: nombre.trim(),
        contacto: contacto ? contacto.trim() : null,
        telefono: telefono ? telefono.trim() : null,
      },
    });

    res.redirect('/laboratorios');
  } catch (error) {
    console.error('Error al crear laboratorio:', error);
    res.render('laboratorios/crear', {
      title: 'Nuevo Laboratorio',
      laboratorio: req.body,
      error: 'Error al crear el laboratorio',
    });
  }
};

// Ver detalle de laboratorio
const show = async (req, res) => {
  try {
    const { id } = req.params;
    const laboratorio = await prisma.laboratorio.findUnique({
      where: { id: parseInt(id) },
    });

    if (!laboratorio) {
      return res.status(404).render('error', {
        title: 'Laboratorio no encontrado',
        message: 'El laboratorio solicitado no existe',
      });
    }

    res.render('laboratorios/ver', {
      title: 'Detalle de Laboratorio',
      laboratorio,
    });
  } catch (error) {
    console.error('Error al obtener laboratorio:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar laboratorio', error });
  }
};

// Mostrar formulario de editar
const edit = async (req, res) => {
  try {
    const { id } = req.params;
    const laboratorio = await prisma.laboratorio.findUnique({
      where: { id: parseInt(id) },
    });

    if (!laboratorio) {
      return res.status(404).render('error', {
        title: 'Laboratorio no encontrado',
        message: 'El laboratorio solicitado no existe',
      });
    }

    res.render('laboratorios/editar', {
      title: 'Editar Laboratorio',
      laboratorio,
      error: null,
    });
  } catch (error) {
    console.error('Error al obtener laboratorio:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar laboratorio', error });
  }
};

// Actualizar laboratorio
const update = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, contacto, telefono } = req.body;

    if (!nombre || nombre.trim() === '') {
      const laboratorio = await prisma.laboratorio.findUnique({
        where: { id: parseInt(id) },
      });
      return res.render('laboratorios/editar', {
        title: 'Editar Laboratorio',
        laboratorio: { ...laboratorio, ...req.body },
        error: 'El nombre es requerido',
      });
    }

    await prisma.laboratorio.update({
      where: { id: parseInt(id) },
      data: {
        nombre: nombre.trim(),
        contacto: contacto ? contacto.trim() : null,
        telefono: telefono ? telefono.trim() : null,
      },
    });

    res.redirect('/laboratorios');
  } catch (error) {
    console.error('Error al actualizar laboratorio:', error);
    const laboratorio = await prisma.laboratorio.findUnique({
      where: { id: parseInt(req.params.id) },
    });
    res.render('laboratorios/editar', {
      title: 'Editar Laboratorio',
      laboratorio: { ...laboratorio, ...req.body },
      error: 'Error al actualizar el laboratorio',
    });
  }
};

// Eliminar laboratorio (soft delete)
const destroy = async (req, res) => {
  try {
    const { id } = req.params;
    await prisma.laboratorio.update({
      where: { id: parseInt(id) },
      data: { activo: false },
    });

    res.redirect('/laboratorios');
  } catch (error) {
    console.error('Error al eliminar laboratorio:', error);
    res.redirect('/laboratorios');
  }
};

module.exports = {
  index,
  create,
  store,
  show,
  edit,
  update,
  destroy,
};



