import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_ai_model_settings_barrel.dart';

class ITAIProvidersSection extends StatelessWidget {
  final bool isDark;
  final AIProvider selectedProvider;
  final AIModel selectedModel;
  final ValueChanged<AIProvider> onProviderChanged;
  final ValueChanged<AIModel> onModelChanged;

  const ITAIProvidersSection({
    super.key,
    required this.isDark,
    required this.selectedProvider,
    required this.selectedModel,
    required this.onProviderChanged,
    required this.onModelChanged,
  });

  List<AIModel> get _availableModels {
    switch (selectedProvider) {
      case AIProvider.openai:
        return [AIModel.gpt4Turbo, AIModel.gpt4, AIModel.gpt35Turbo];
      case AIProvider.gemini:
        return [AIModel.geminiPro, AIModel.gemini15Pro];
      case AIProvider.claude:
        return [
          AIModel.claude35Sonnet,
          AIModel.claude3Sonnet,
          AIModel.claude3Opus,
        ];
    }
  }

  String _getModelName(AIModel model) {
    switch (model) {
      case AIModel.gpt4Turbo:
        return 'GPT-4.1 Turbo';
      case AIModel.gpt4:
        return 'GPT-4';
      case AIModel.gpt35Turbo:
        return 'GPT-3.5 Turbo';
      case AIModel.geminiPro:
        return 'Gemini Pro';
      case AIModel.gemini15Pro:
        return 'Gemini 1.5 Pro';
      case AIModel.claude3Opus:
        return 'Claude 3 Opus';
      case AIModel.claude3Sonnet:
        return 'Claude 3 Sonnet';
      case AIModel.claude35Sonnet:
        return 'Claude 3.5 Sonnet';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ITColors.purple.withValues(alpha: 0.2),
                      ITColors.primary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: ITColors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Providers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select and configure AI service providers',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Provider Selection
          Text(
            'Select Provider',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ITColors.textSecondaryColor(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildProviderToggle(),
          const SizedBox(height: 20),

          // Model Selection
          Text(
            'Select Model',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ITColors.textSecondaryColor(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildModelDropdown(),
        ],
      ),
    );
  }

  Widget _buildProviderToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: AIProvider.values.map((provider) {
          final isSelected = selectedProvider == provider;
          return Expanded(
            child: GestureDetector(
              onTap: () => onProviderChanged(provider),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getProviderColor(provider)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getProviderColor(
                              provider,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getProviderIcon(provider),
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : ITColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _getProviderName(provider),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : ITColors.textSecondaryColor(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModelDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AIModel>(
          value: _availableModels.contains(selectedModel)
              ? selectedModel
              : _availableModels.first,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ITColors.textSecondaryColor(isDark),
          ),
          dropdownColor: isDark ? ITColors.darkCard : Colors.white,
          items: _availableModels.map((model) {
            return DropdownMenuItem<AIModel>(
              value: model,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getProviderColor(
                        selectedProvider,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.memory_rounded,
                      size: 16,
                      color: _getProviderColor(selectedProvider),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getModelName(model),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ITColors.textPrimaryColor(isDark),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (model) {
            if (model != null) {
              onModelChanged(model);
            }
          },
        ),
      ),
    );
  }

  Color _getProviderColor(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return const Color(0xFF10A37F);
      case AIProvider.gemini:
        return const Color(0xFF4285F4);
      case AIProvider.claude:
        return const Color(0xFFD97706);
    }
  }

  IconData _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return Icons.auto_awesome;
      case AIProvider.gemini:
        return Icons.diamond_outlined;
      case AIProvider.claude:
        return Icons.psychology;
    }
  }

  String _getProviderName(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.gemini:
        return 'Gemini';
      case AIProvider.claude:
        return 'Claude';
    }
  }
}
