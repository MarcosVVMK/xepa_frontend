import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:xepa_frontend/core/DI/dependency_injection.dart';
import 'package:xepa_frontend/core/auth/token_storage.dart';
import 'package:xepa_frontend/features/auth/data/models/user_model.dart';

import 'package:xepa_frontend/features/auth/presentation/pages/login_screen.dart';
import 'package:xepa_frontend/core/services/i_geocoding_service.dart';
import 'package:xepa_frontend/core/services/i_zipcode_service.dart';
import 'package:xepa_frontend/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:xepa_frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:xepa_frontend/features/profile/domain/usecases/save_address_usecase.dart';
import 'package:xepa_frontend/features/profile/domain/usecases/delete_account_usecase.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _getProfileUseCase = getIt<GetProfileUseCase>();
  final _updateProfileUseCase = getIt<UpdateProfileUseCase>();
  final _saveAddressUseCase = getIt<SaveAddressUseCase>();
  final _deleteAccountUseCase = getIt<DeleteAccountUseCase>();

  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditingPersonal = false;
  bool _isEditingAddress = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();

  final _zipCodeController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final result = await _getProfileUseCase();

      result.fold(
        (failure) {
          dev.log('Erro ao carregar dados do usuário: ${failure.message}');
          if (mounted) setState(() => _isLoading = false);
        },
        (profile) {
          if (mounted) {
            setState(() {
              _user = UserModel(
                id: profile.id,
                firstName: profile.firstName,
                lastName: profile.lastName,
                email: profile.email,
                cpf: profile.cpf,
                phone: profile.phone,
                address: profile.address,
                createdAt: profile.createdAt,
              );

              _firstNameController.text = profile.firstName;
              _lastNameController.text = profile.lastName;
              _emailController.text = profile.email;
              _phoneController.text = _formatPhone(profile.phone);
              _cpfController.text = _formatCpf(profile.cpf);

              if (profile.address != null) {
                final address = profile.address!;
                _zipCodeController.text = _formatCep(address.zipCode);
                _streetController.text = address.street;
                _numberController.text = address.number;
                _complementController.text = address.complement;
                _neighborhoodController.text = address.neighborhood;
                _cityController.text = address.city;
                _stateController.text = address.uf;
              }
              _isLoading = false;
            });
          }
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        'Exceção ao carregar dados do usuário',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePersonalData() async {
    setState(() => _isSaving = true);

    try {
      final result = await _updateProfileUseCase(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        cpf: _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );

      result.fold(
        (failure) {
          dev.log('Erro ao salvar dados pessoais: ${failure.message}');
          if (mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao salvar dados pessoais: ${failure.message}'),
                backgroundColor: const Color(0xFFEF5350),
              ),
            );
          }
        },
        (profile) {
          if (mounted) {
            setState(() {
              _isSaving = false;
              _isEditingPersonal = false;
              _user = UserModel.fromProfile(profile);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dados pessoais atualizados!'),
                backgroundColor: Color(0xFF66BB6A),
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        'Exceção ao salvar dados pessoais',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro inesperado ao salvar dados pessoais!'),
            backgroundColor: Color(0xFFEF5350),
          ),
        );
      }
    }
  }

  Future<void> _saveAddress() async {
    setState(() => _isSaving = true);

    try {
      double? latitude;
      double? longitude;

      try {
        final geocodingService = getIt<IGeocodingService>();
        final addressStr =
            '${_streetController.text}, ${_numberController.text}, ${_cityController.text}, ${_stateController.text}';
        final geoResult = await geocodingService.getCoordinatesFromAddress(
          addressStr,
        );

        geoResult.fold((failure) => null, (coords) {
          latitude = coords['latitude'];
          longitude = coords['longitude'];
        });
      } catch (e, stackTrace) {
        dev.log(
          'Erro ao obter coordenadas (geocodificação)',
          error: e,
          stackTrace: stackTrace,
        );
      }

      final result = await _saveAddressUseCase(
        zipCode: _zipCodeController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        street: _streetController.text,
        number: _numberController.text,
        complement: _complementController.text,
        neighborhood: _neighborhoodController.text,
        city: _cityController.text,
        state: _stateController.text,
        uf: _stateController.text,
        latitude: latitude,
        longitude: longitude,
      );

      result.fold(
        (failure) {
          dev.log('Erro ao salvar endereço: ${failure.message}');
          if (mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao salvar endereço: ${failure.message}'),
                backgroundColor: const Color(0xFFEF5350),
              ),
            );
          }
        },
        (address) {
          if (mounted) {
            setState(() {
              _isSaving = false;
              _isEditingAddress = false;
              if (_user != null) {
                _user = UserModel(
                  id: _user!.id,
                  firstName: _user!.firstName,
                  lastName: _user!.lastName,
                  email: _user!.email,
                  cpf: _user!.cpf,
                  phone: _user!.phone,
                  address: address,
                  createdAt: _user!.createdAt,
                );
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Endereço atualizado!'),
                backgroundColor: Color(0xFF66BB6A),
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        'Exceção ao salvar endereço',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro inesperado ao salvar endereço!'),
            backgroundColor: Color(0xFFEF5350),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final tokenStorage = getIt<TokenStorage>();
    await tokenStorage.deleteToken();
    await tokenStorage.deleteUser();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? '
          'Todos os seus dados pessoais serão removidos permanentemente. '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF5350),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _deleteAccountUseCase();

      result.fold(
        (failure) {
          dev.log('Erro ao excluir conta: ${failure.message}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao excluir conta: ${failure.message}'),
                backgroundColor: const Color(0xFFEF5350),
              ),
            );
          }
        },
        (_) async {
          final tokenStorage = getIt<TokenStorage>();
          await tokenStorage.deleteToken();
          await tokenStorage.deleteUser();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conta excluída com sucesso.'),
                backgroundColor: Color(0xFF66BB6A),
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      dev.log('Exceção ao excluir conta', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro inesperado ao excluir conta. Tente novamente.'),
            backgroundColor: Color(0xFFEF5350),
          ),
        );
      }
    }
  }

  String get _userInitials {
    if (_user == null) return '?';
    final first = _user!.firstName.isNotEmpty ? _user!.firstName[0] : '';
    final last = _user!.lastName.isNotEmpty ? _user!.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Dados Pessoais',
                icon: Icons.person_outline_rounded,
                isEditing: _isEditingPersonal,
                onEditToggle: () =>
                    setState(() => _isEditingPersonal = !_isEditingPersonal),
                onSave: _savePersonalData,
                child: _buildPersonalDataForm(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Endereço',
                icon: Icons.location_on_outlined,
                isEditing: _isEditingAddress,
                onEditToggle: () =>
                    setState(() => _isEditingAddress = !_isEditingAddress),
                onSave: _saveAddress,
                child: _buildAddressForm(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text(
                      'Sair da conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF5350),
                      side: const BorderSide(color: Color(0xFFEF5350)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever_rounded, size: 20),
                    label: const Text(
                      'Excluir minha conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                      side: const BorderSide(color: Color(0xFFD32F2F)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Meu Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                _userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _user != null
                ? '${_user!.firstName} ${_user!.lastName}'
                : 'Usuário',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isEditing,
    required VoidCallback onEditToggle,
    required VoidCallback onSave,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 10, 8),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2196F3), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isSaving ? null : onEditToggle,
                  icon: Icon(
                    isEditing ? Icons.close_rounded : Icons.edit_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isEditing ? 'Cancelar' : 'Editar',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: isEditing
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(18), child: child),
          if (isEditing) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(18),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : onSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(
                    _isSaving ? 'Salvando...' : 'Salvar Alterações',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalDataForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildField(
                label: 'Nome',
                controller: _firstNameController,
                enabled: _isEditingPersonal,
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildField(
                label: 'Sobrenome',
                controller: _lastNameController,
                enabled: _isEditingPersonal,
                icon: Icons.person_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildField(
          label: 'E-mail',
          controller: _emailController,
          enabled: _isEditingPersonal,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildField(
          label: 'Telefone',
          controller: _phoneController,
          enabled: _isEditingPersonal,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [_phoneMask],
        ),
        const SizedBox(height: 14),
        _buildField(
          label: 'CPF',
          controller: _cpfController,
          enabled: false,
          icon: Icons.badge_outlined,
          inputFormatters: [_cpfMask],
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    final hasAddress = _zipCodeController.text.isNotEmpty;

    if (!hasAddress && !_isEditingAddress) {
      return Column(
        children: [
          Icon(Icons.location_off_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Nenhum endereço cadastrado',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() => _isEditingAddress = true),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'Adicionar endereço',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2196F3),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildField(
                label: 'CEP',
                controller: _zipCodeController,
                enabled: _isEditingAddress,
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [_cepMask],
              ),
            ),
            if (_isEditingAddress) ...[
              const SizedBox(width: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final cep = _cepMask.getUnmaskedText();
                          if (cep.length == 8) {
                            setState(() => _isSaving = true);
                            try {
                              final zipCodeService = getIt<IZipCodeService>();
                              final result = await zipCodeService
                                  .getAddressByZipCode(cep);

                              result.fold(
                                (failure) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(failure.message),
                                        backgroundColor: const Color(
                                          0xFFEF5350,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                (data) {
                                  if (mounted) {
                                    setState(() {
                                      _streetController.text =
                                          data['street'] ?? '';
                                      _neighborhoodController.text =
                                          data['neighborhood'] ?? '';
                                      _cityController.text = data['city'] ?? '';
                                      _stateController.text =
                                          data['state'] ?? '';
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Endereço encontrado!'),
                                        backgroundColor: Color(0xFF66BB6A),
                                      ),
                                    );
                                  }
                                },
                              );
                            } catch (e, stackTrace) {
                              dev.log(
                                'Erro ao buscar CEP',
                                error: e,
                                stackTrace: stackTrace,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erro ao buscar CEP!'),
                                    backgroundColor: Color(0xFFEF5350),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isSaving = false);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Digite um CEP válido com 8 dígitos!',
                                ),
                                backgroundColor: Color(0xFFEF5350),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Buscar'),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        _buildField(
          label: 'Rua',
          controller: _streetController,
          enabled: _isEditingAddress,
          icon: Icons.signpost_outlined,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildField(
                label: 'Número',
                controller: _numberController,
                enabled: _isEditingAddress,
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildField(
                label: 'Complemento',
                controller: _complementController,
                enabled: _isEditingAddress,
                icon: Icons.apartment_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildField(
          label: 'Bairro',
          controller: _neighborhoodController,
          enabled: _isEditingAddress,
          icon: Icons.map_outlined,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildField(
                label: 'Cidade',
                controller: _cityController,
                enabled: _isEditingAddress,
                icon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildField(
                label: 'UF',
                controller: _stateController,
                enabled: _isEditingAddress,
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    IconData? icon,
    TextInputType? keyboardType,
    List<dynamic>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters?.cast(),
      style: TextStyle(
        color: enabled ? const Color(0xFF1F2937) : Colors.grey[600],
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? const Color(0xFF2196F3) : Colors.grey[400],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                size: 20,
                color: enabled ? const Color(0xFF2196F3) : Colors.grey[400],
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  String _formatCpf(String cpf) {
    final digits = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 11) return cpf;
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
  }

  String _formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 11) return phone;
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
  }

  String _formatCep(String cep) {
    final digits = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 8) return cep;
    return '${digits.substring(0, 5)}-${digits.substring(5)}';
  }
}
