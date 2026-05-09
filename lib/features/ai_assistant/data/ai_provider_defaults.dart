import '../domain/ai_assistant_models.dart';

const List<AiModelDescriptor> kAiDefaultModels = <AiModelDescriptor>[
  AiModelDescriptor(
    providerId: AiProviderId.gemini,
    modelId: 'gemini-2.5-flash',
    label: 'Gemini 2.5 Flash',
    isFreeTier: true,
    status: 'stable',
    description: 'Fast general-purpose Gemini model.',
    capabilities: AiProviderCapabilities(
      supportsReasoning: true,
      supportsToolCalling: true,
    ),
  ),
  AiModelDescriptor(
    providerId: AiProviderId.gemini,
    modelId: 'gemini-2.5-flash-lite',
    label: 'Gemini 2.5 Flash Lite',
    isFreeTier: true,
    status: 'preview',
    description: 'Lower-cost Gemini fallback if available.',
  ),
  AiModelDescriptor(
    providerId: AiProviderId.groq,
    modelId: 'llama-3.1-8b-instant',
    label: 'Llama 3.1 8B Instant',
    isFreeTier: true,
    status: 'stable',
  ),
  AiModelDescriptor(
    providerId: AiProviderId.groq,
    modelId: 'llama-3.3-70b-versatile',
    label: 'Llama 3.3 70B Versatile',
    isFreeTier: true,
    status: 'stable',
  ),
  AiModelDescriptor(
    providerId: AiProviderId.groq,
    modelId: 'openai/gpt-oss-20b',
    label: 'GPT OSS 20B',
    isFreeTier: true,
    status: 'stable',
  ),
  AiModelDescriptor(
    providerId: AiProviderId.groq,
    modelId: 'qwen/qwen3-32b',
    label: 'Qwen3 32B',
    isFreeTier: true,
    status: 'stable',
    capabilities: AiProviderCapabilities(supportsReasoning: true),
  ),
  AiModelDescriptor(
    providerId: AiProviderId.openRouter,
    modelId: 'openrouter/free',
    label: 'OpenRouter Free Router',
    isFreeTier: true,
    status: 'dynamic',
    description: 'Automatic routing across currently available free models.',
    capabilities: AiProviderCapabilities(
      supportsVision: true,
      supportsReasoning: true,
      supportsToolCalling: true,
      dynamicCatalog: true,
    ),
  ),
  AiModelDescriptor(
    providerId: AiProviderId.openRouter,
    modelId: 'meta-llama/llama-3.2-3b-instruct:free',
    label: 'Llama 3.2 3B Instruct (Free)',
    isFreeTier: true,
    status: 'dynamic',
  ),
];

List<AiModelDescriptor> defaultModelsForProvider(AiProviderId providerId) {
  return kAiDefaultModels
      .where((model) => model.providerId == providerId)
      .toList(growable: false);
}

AiModelDescriptor? findDefaultModel(AiProviderId providerId, String modelId) {
  for (final model in kAiDefaultModels) {
    if (model.providerId == providerId && model.modelId == modelId) {
      return model;
    }
  }
  return null;
}
