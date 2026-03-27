import { useState, useEffect } from 'react';
import axios, { AxiosError } from 'axios';
import { SelectChangeEvent } from '@mui/material';
import {
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  Dialog,
  TextField,
  Box,
  IconButton,
  Card,
  CardMedia,
  Grid,
  CircularProgress,
  Alert,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
} from '@mui/material';
import { Edit as EditIcon, Delete as DeleteIcon, Add as AddIcon, CloudUpload as CloudUploadIcon } from '@mui/icons-material';
import MainLayout from '../components/MainLayout';

interface Service {
  id: string;
  name: string;
  description: string;
  category: string;
  image1?: string;
  image2?: string;
}

interface FormDataType {
  name: string;
  description: string;
  category: string;
  image1: File | null;
  image2: File | null;
}

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

const ServicesManagement = () => {
  const [services, setServices] = useState<Service[]>([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [formData, setFormData] = useState<FormDataType>({
    name: '',
    description: '',
    category: '',
    image1: null,
    image2: null,
  });
  const [imagePreview, setImagePreview] = useState({
    image1: null as string | null,
    image2: null as string | null,
  });

  const CATEGORIES = ['Heavy Machinery', 'Utilities', 'Transport', 'Equipment', 'Tools'];

  // Fetch services
  useEffect(() => {
    fetchServices();
  }, []);

  const fetchServices = async () => {
    try {
      setLoading(true);
      const response = await axios.get<any>(`${API_BASE_URL}/services`);
      const servicesData = response.data?.data || [];
      setServices(servicesData);
    } catch (err) {
      const error = err as AxiosError<any>;
      setError('Failed to fetch services: ' + (error.response?.data?.message || error.message));
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDialog = (service: Service | null = null) => {
    if (service) {
      setEditingId(service.id);
      setFormData({
        name: service.name,
        description: service.description,
        category: service.category,
        image1: null,
        image2: null,
      });
      setImagePreview({
        image1: service.image1 || null,
        image2: service.image2 || null,
      });
    } else {
      setEditingId(null);
      setFormData({
        name: '',
        description: '',
        category: '',
        image1: null,
        image2: null,
      });
      setImagePreview({ image1: null, image2: null });
    }
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setEditingId(null);
    setError('');
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>, imageField: 'image1' | 'image2') => {
    const file = e.target.files?.[0];
    if (file) {
      setFormData({ ...formData, [imageField]: file });
      const reader = new FileReader();
      reader.onload = (event) => {
        const result = event.target?.result as string;
        setImagePreview({ ...imagePreview, [imageField]: result });
      };
      reader.readAsDataURL(file);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | { name?: string; value: unknown }>) => {
    const target = e.target as HTMLInputElement | HTMLSelectElement;
    const { name, value } = target;
    setFormData({ ...formData, [name]: value } as FormDataType);
  };

  const handleCategoryChange = (e: SelectChangeEvent<string>) => {
    setFormData({ ...formData, category: e.target.value });
  };

  const handleSave = async () => {
    try {
      setError('');

      if (!formData.name || !formData.description || !formData.category) {
        setError('Name, description, and category are required');
        return;
      }

      if (!editingId && (!formData.image1 || !formData.image2)) {
        setError('Both images are required for new services');
        return;
      }

      setLoading(true);
      const serviceId = editingId || Date.now().toString();

      // Create FormData for multipart upload
      const uploadFormData = new FormData();
      uploadFormData.append('name', formData.name);
      uploadFormData.append('description', formData.description);
      uploadFormData.append('category', formData.category);
      
      if (formData.image1) {
        uploadFormData.append('image1', formData.image1);
      }
      if (formData.image2) {
        uploadFormData.append('image2', formData.image2);
      }

      if (editingId) {
        // Update service
        await axios.put(
          `${API_BASE_URL}/services/${editingId}`,
          uploadFormData,
          { headers: { 'Content-Type': 'multipart/form-data' } }
        );
        setSuccess('Service updated successfully');
      } else {
        // Create new service
        uploadFormData.append('id', serviceId);
        await axios.post(
          `${API_BASE_URL}/services`,
          uploadFormData,
          { headers: { 'Content-Type': 'multipart/form-data' } }
        );
        setSuccess('Service created successfully');
      }

      handleCloseDialog();
      fetchServices();
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      const error = err as AxiosError<any>;
      setError('Error: ' + (error.response?.data?.message || error.message));
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (serviceId: string) => {
    if (!window.confirm('Are you sure you want to delete this service?')) return;

    try {
      setLoading(true);
      await axios.delete(`${API_BASE_URL}/services/${serviceId}`);
      setSuccess('Service deleted successfully');
      fetchServices();
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      const error = err as AxiosError<any>;
      setError('Error: ' + (error.response?.data?.message || error.message));
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <MainLayout>
      <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" sx={{ fontWeight: 'bold' }}>
          Services Management
        </Typography>
        <Button
          variant="contained"
          color="primary"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
          sx={{
            backgroundColor: '#1976d2',
            '&:hover': { backgroundColor: '#1565c0' },
            px: 3,
            py: 1,
          }}
        >
          Add New Service
        </Button>
      </Box>

      {/* Alerts */}
      {error && <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError('')}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess('')}>{success}</Alert>}

      {/* Manage Services Content */}
      <Box>
        {loading && services.length === 0 ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
            <CircularProgress />
          </Box>
        ) : services.length === 0 ? (
          <Alert severity="info">No services yet. Click "Add New Service" to get started!</Alert>
        ) : (
          <TableContainer component={Paper}>
              <Table>
                <TableHead sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableRow>
                    <TableCell sx={{ fontWeight: 'bold' }}>Service Name</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>Category</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>Description</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>Images</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }} align="right">
                      Actions
                    </TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {services.map((service) => (
                    <TableRow key={service.id} hover>
                      <TableCell sx={{ fontWeight: '500' }}>{service.name}</TableCell>
                      <TableCell>
                        <Chip label={service.category} size="small" />
                      </TableCell>
                      <TableCell sx={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis' }}>
                        {service.description}
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 1 }}>
                          {service.image1 && (
                            <img
                              src={service.image1}
                              alt="img1"
                              style={{ width: 40, height: 40, borderRadius: 4, objectFit: 'cover' }}
                              onError={(e) => {
                                (e.target as HTMLImageElement).src = 'https://via.placeholder.com/40';
                              }}
                            />
                          )}
                          {service.image2 && (
                            <img
                              src={service.image2}
                              alt="img2"
                              style={{ width: 40, height: 40, borderRadius: 4, objectFit: 'cover' }}
                              onError={(e) => {
                                (e.target as HTMLImageElement).src = 'https://via.placeholder.com/40';
                              }}
                            />
                          )}
                        </Box>
                      </TableCell>
                      <TableCell align="right">
                        <IconButton
                          size="small"
                          color="primary"
                          onClick={() => handleOpenDialog(service)}
                          title="Edit"
                        >
                          <EditIcon />
                        </IconButton>
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => handleDelete(service.id)}
                          title="Delete"
                        >
                          <DeleteIcon />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </Box>

      {/* Add/Edit Service Dialog */}
      <Dialog
        open={openDialog}
        onClose={handleCloseDialog}
        maxWidth="sm"
        fullWidth
        PaperProps={{
          sx: {
            borderRadius: 2,
            boxShadow: '0 8px 32px rgba(0,0,0,0.1)',
          },
        }}
      >
        <Box sx={{ p: 3 }}>
          <Typography variant="h5" sx={{ fontWeight: 'bold', mb: 2 }}>
            {editingId ? 'Edit Service' : 'Add New Service'}
          </Typography>

          {error && <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError('')}>{error}</Alert>}

          <TextField
            fullWidth
            label="Service Name"
            name="name"
            value={formData.name}
            onChange={handleInputChange}
            margin="normal"
            variant="outlined"
            placeholder="e.g., Excavator Rental"
          />

          <FormControl fullWidth margin="normal">
            <InputLabel>Category</InputLabel>
            <Select
              name="category"
              value={formData.category}
              onChange={handleCategoryChange}
              label="Category"
            >
              {CATEGORIES.map((cat) => (
                <MenuItem key={cat} value={cat}>
                  {cat}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <TextField
            fullWidth
            label="Description"
            name="description"
            value={formData.description}
            onChange={handleInputChange}
            margin="normal"
            multiline
            rows={3}
            variant="outlined"
            placeholder="Describe your service..."
          />

          {/* Image Upload Section */}
          <Typography variant="subtitle2" sx={{ fontWeight: 'bold', mt: 2, mb: 1 }}>
            Service Images <span style={{ color: '#d32f2f' }}>*</span>
          </Typography>

          <Grid container spacing={2} sx={{ mb: 2 }}>
            {/* Image 1 */}
            <Grid item xs={12} sm={6}>
              <Paper
                sx={{
                  border: '2px dashed #1976d2',
                  borderRadius: 2,
                  p: 2,
                  textAlign: 'center',
                  backgroundColor: '#f5f5f5',
                  cursor: 'pointer',
                  transition: 'all 0.3s',
                  '&:hover': {
                    backgroundColor: '#e3f2fd',
                  },
                }}
                component="label"
              >
                {!imagePreview.image1 ? (
                  <Box sx={{ py: 2 }}>
                    <CloudUploadIcon sx={{ fontSize: 40, color: '#1976d2', mb: 1 }} />
                    <Typography variant="body2" sx={{ color: '#666' }}>
                      Click to upload Image 1
                    </Typography>
                  </Box>
                ) : (
                  <Box>
                    <Card sx={{ mb: 1 }}>
                      <CardMedia
                        component="img"
                        height="120"
                        image={
                          typeof imagePreview.image1 === 'string' && imagePreview.image1.startsWith('http')
                            ? imagePreview.image1
                            : imagePreview.image1
                        }
                        alt="Preview 1"
                        sx={{ objectFit: 'cover' }}
                      />
                    </Card>
                    <Typography variant="caption" sx={{ color: '#666' }}>
                      Click to change
                    </Typography>
                  </Box>
                )}
                <input
                  type="file"
                  accept="image/*"
                  hidden
                  onChange={(e) => handleImageChange(e, 'image1')}
                />
              </Paper>
            </Grid>

            {/* Image 2 */}
            <Grid item xs={12} sm={6}>
              <Paper
                sx={{
                  border: '2px dashed #1976d2',
                  borderRadius: 2,
                  p: 2,
                  textAlign: 'center',
                  backgroundColor: '#f5f5f5',
                  cursor: 'pointer',
                  transition: 'all 0.3s',
                  '&:hover': {
                    backgroundColor: '#e3f2fd',
                  },
                }}
                component="label"
              >
                {!imagePreview.image2 ? (
                  <Box sx={{ py: 2 }}>
                    <CloudUploadIcon sx={{ fontSize: 40, color: '#1976d2', mb: 1 }} />
                    <Typography variant="body2" sx={{ color: '#666' }}>
                      Click to upload Image 2
                    </Typography>
                  </Box>
                ) : (
                  <Box>
                    <Card sx={{ mb: 1 }}>
                      <CardMedia
                        component="img"
                        height="120"
                        image={
                          typeof imagePreview.image2 === 'string' && imagePreview.image2.startsWith('http')
                            ? imagePreview.image2
                            : imagePreview.image2
                        }
                        alt="Preview 2"
                        sx={{ objectFit: 'cover' }}
                      />
                    </Card>
                    <Typography variant="caption" sx={{ color: '#666' }}>
                      Click to change
                    </Typography>
                  </Box>
                )}
                <input
                  type="file"
                  accept="image/*"
                  hidden
                  onChange={(e) => handleImageChange(e, 'image2')}
                />
              </Paper>
            </Grid>
          </Grid>

          {/* Action Buttons */}
          <Box sx={{ display: 'flex', gap: 2, mt: 3, justifyContent: 'flex-end' }}>
            <Button onClick={handleCloseDialog} variant="outlined" sx={{ px: 3 }}>
              Cancel
            </Button>
            <Button
              onClick={handleSave}
              variant="contained"
              disabled={loading}
              sx={{
                px: 3,
                backgroundColor: '#1976d2',
                '&:hover': { backgroundColor: '#1565c0' },
              }}
            >
              {loading ? <CircularProgress size={24} /> : editingId ? 'Update Service' : 'Add Service'}
            </Button>
          </Box>
        </Box>
      </Dialog>
    </Box>
    </MainLayout>
  );
};

export default ServicesManagement;
