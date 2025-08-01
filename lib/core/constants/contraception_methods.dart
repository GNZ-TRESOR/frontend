import '../models/contraception_method.dart';

/// Predefined contraception methods based on real-world options
/// Organized by contraception type for easy selection
class ContraceptionMethods {
  
  /// Get all predefined method names for a specific type
  static List<String> getMethodNamesForType(ContraceptionType type) {
    switch (type) {
      case ContraceptionType.pill:
        return _pillMethods;
      case ContraceptionType.injection:
        return _injectionMethods;
      case ContraceptionType.implant:
        return _implantMethods;
      case ContraceptionType.iud:
        return _iudMethods;
      case ContraceptionType.condom:
        return _condomMethods;
      case ContraceptionType.diaphragm:
        return _diaphragmMethods;
      case ContraceptionType.patch:
        return _patchMethods;
      case ContraceptionType.ring:
        return _ringMethods;
      case ContraceptionType.naturalFamilyPlanning:
        return _naturalMethods;
      case ContraceptionType.sterilization:
        return _sterilizationMethods;
      case ContraceptionType.emergencyContraception:
        return _emergencyMethods;
      case ContraceptionType.other:
        return _otherMethods;
    }
  }

  /// Get method details including typical effectiveness
  static Map<String, dynamic>? getMethodDetails(String methodName) {
    return _methodDetails[methodName];
  }

  /// Birth Control Pills
  static const List<String> _pillMethods = [
    'Combined Oral Contraceptive Pill (COC)',
    'Progestin-Only Pill (Mini-Pill)',
    'Yasmin (Drospirenone/Ethinyl Estradiol)',
    'Ortho Tri-Cyclen (Norgestimate/Ethinyl Estradiol)',
    'Loestrin (Norethindrone/Ethinyl Estradiol)',
    'Alesse (Levonorgestrel/Ethinyl Estradiol)',
    'Seasonique (Extended Cycle)',
    'Yaz (Drospirenone/Ethinyl Estradiol)',
    'Micronor (Norethindrone)',
    'Cerazette (Desogestrel)',
  ];

  /// Injectable Contraceptives
  static const List<String> _injectionMethods = [
    'Depo-Provera (DMPA)',
    'Sayana Press (Subcutaneous DMPA)',
    'Noristerat (NET-EN)',
    'Cyclofem (Monthly Injectable)',
    'Mesigyna (Monthly Injectable)',
  ];

  /// Contraceptive Implants
  static const List<String> _implantMethods = [
    'Nexplanon (Single Rod)',
    'Implanon (Single Rod)',
    'Jadelle (Two Rods)',
    'Norplant (Six Rods)',
    'Sino-implant (Two Rods)',
  ];

  /// Intrauterine Devices (IUDs)
  static const List<String> _iudMethods = [
    'Mirena IUD (Hormonal)',
    'Skyla IUD (Hormonal)',
    'Liletta IUD (Hormonal)',
    'Kyleena IUD (Hormonal)',
    'Copper T 380A (Non-hormonal)',
    'ParaGard (Copper IUD)',
    'Multiload Cu375',
    'Nova T 380',
  ];

  /// Barrier Methods - Condoms
  static const List<String> _condomMethods = [
    'Male Latex Condoms',
    'Male Non-Latex Condoms',
    'Female Condoms (Internal Condoms)',
    'Polyurethane Condoms',
    'Lambskin Condoms',
    'Textured Condoms',
    'Ultra-Thin Condoms',
  ];

  /// Barrier Methods - Diaphragms
  static const List<String> _diaphragmMethods = [
    'Latex Diaphragm',
    'Silicone Diaphragm',
    'Caya Diaphragm',
    'Cervical Cap',
    'FemCap',
    'Lea\'s Shield',
  ];

  /// Contraceptive Patches
  static const List<String> _patchMethods = [
    'Ortho Evra Patch',
    'Xulane Patch',
    'Evra Patch',
  ];

  /// Vaginal Rings
  static const List<String> _ringMethods = [
    'NuvaRing',
    'Annovera Ring',
    'EluRyng',
  ];

  /// Natural Family Planning
  static const List<String> _naturalMethods = [
    'Fertility Awareness Method (FAM)',
    'Basal Body Temperature Method',
    'Cervical Mucus Method',
    'Calendar/Rhythm Method',
    'Symptothermal Method',
    'Lactational Amenorrhea Method (LAM)',
    'Withdrawal (Coitus Interruptus)',
  ];

  /// Sterilization Methods
  static const List<String> _sterilizationMethods = [
    'Tubal Ligation (Female)',
    'Vasectomy (Male)',
    'Essure (Tubal Occlusion)',
    'Bilateral Salpingectomy',
  ];

  /// Emergency Contraception
  static const List<String> _emergencyMethods = [
    'Plan B One-Step (Levonorgestrel)',
    'ella (Ulipristal Acetate)',
    'Copper IUD (Emergency)',
    'Generic Levonorgestrel',
    'Next Choice',
  ];

  /// Other Methods
  static const List<String> _otherMethods = [
    'Spermicide (Nonoxynol-9)',
    'Contraceptive Sponge',
    'Abstinence',
    'Custom/Other Method',
  ];

  /// Method details with typical effectiveness and descriptions
  static const Map<String, Map<String, dynamic>> _methodDetails = {
    // Pills
    'Combined Oral Contraceptive Pill (COC)': {
      'effectiveness': 91.0,
      'description': 'Daily oral contraceptive containing estrogen and progestin',
      'instructions': 'Take one pill daily at the same time',
    },
    'Progestin-Only Pill (Mini-Pill)': {
      'effectiveness': 91.0,
      'description': 'Daily oral contraceptive containing only progestin',
      'instructions': 'Take one pill daily at the same time, no hormone-free interval',
    },

    // Injections
    'Depo-Provera (DMPA)': {
      'effectiveness': 94.0,
      'description': 'Injectable contraceptive given every 3 months',
      'instructions': 'Injection every 12-13 weeks',
    },
    'Sayana Press (Subcutaneous DMPA)': {
      'effectiveness': 94.0,
      'description': 'Self-injectable contraceptive given every 3 months',
      'instructions': 'Self-injection every 13 weeks',
    },

    // Implants
    'Nexplanon (Single Rod)': {
      'effectiveness': 99.0,
      'description': 'Single rod implant effective for 3 years',
      'instructions': 'Inserted under skin of upper arm, effective for 3 years',
    },
    'Jadelle (Two Rods)': {
      'effectiveness': 99.0,
      'description': 'Two rod implant effective for 5 years',
      'instructions': 'Inserted under skin of upper arm, effective for 5 years',
    },

    // IUDs
    'Mirena IUD (Hormonal)': {
      'effectiveness': 99.0,
      'description': 'Hormonal IUD effective for 5-7 years',
      'instructions': 'Inserted by healthcare provider, check strings monthly',
    },
    'Copper T 380A (Non-hormonal)': {
      'effectiveness': 99.0,
      'description': 'Copper IUD effective for 10-12 years',
      'instructions': 'Inserted by healthcare provider, check strings monthly',
    },

    // Condoms
    'Male Latex Condoms': {
      'effectiveness': 82.0,
      'description': 'Barrier method that also prevents STIs',
      'instructions': 'Use new condom for each act of intercourse',
    },
    'Female Condoms (Internal Condoms)': {
      'effectiveness': 79.0,
      'description': 'Internal barrier method that also prevents STIs',
      'instructions': 'Insert before intercourse, use new one each time',
    },

    // Natural Methods
    'Fertility Awareness Method (FAM)': {
      'effectiveness': 76.0,
      'description': 'Tracking fertility signs to avoid pregnancy',
      'instructions': 'Track basal body temperature, cervical mucus, and cycle',
    },
    'Withdrawal (Coitus Interruptus)': {
      'effectiveness': 78.0,
      'description': 'Male partner withdraws before ejaculation',
      'instructions': 'Requires significant self-control and experience',
    },

    // Emergency
    'Plan B One-Step (Levonorgestrel)': {
      'effectiveness': 89.0,
      'description': 'Emergency contraception taken within 72 hours',
      'instructions': 'Take as soon as possible after unprotected intercourse',
    },
    'ella (Ulipristal Acetate)': {
      'effectiveness': 85.0,
      'description': 'Emergency contraception effective up to 120 hours',
      'instructions': 'Take within 120 hours of unprotected intercourse',
    },
  };
}
