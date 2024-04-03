param profileName string
param securityPolicyName string = 'apim-default-security-policy'
param securityPolicyDomains array = []
param securityPolicyType string = 'WebApplicationFirewall'
param wafDefaultPolicyName string = 'apimdefaultwafpolicy'
param wafPolicySku string = 'Premium_AzureFrontDoor'
param wafPolicyMode string = 'Detection'
param wafPolicyRequestBodyCheck string = 'Enabled'
param wafPolicyManagedCustomRules array = []

var wafPolicyManagedRuleSets = [
  {
    ruleSetType: 'Microsoft_DefaultRuleSet'
    ruleSetVersion: '2.1'
    ruleSetAction: 'Block'
    ruleGroupOverrides: []
    exclusions: []
  }
  {
    ruleSetType: 'Microsoft_BotManagerRuleSet'
    ruleSetVersion: '1.0'
    ruleGroupOverrides: []
    exclusions: []
  }
]

var securityPolicyPatternsToMatch = ['/*']

resource profile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: profileName
}

resource wafPolicy 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies@2022-05-01' = {
  name: wafDefaultPolicyName
  location: 'Global'
  sku: {
    name: wafPolicySku
  }
  properties: {
    policySettings: {
      mode: wafPolicyMode
      requestBodyCheck: wafPolicyRequestBodyCheck
    }
    customRules: {
      rules: wafPolicyManagedCustomRules
    }
    managedRules: {
      managedRuleSets: wafPolicyManagedRuleSets
    }
  }
}

resource securityPolicy 'Microsoft.Cdn/profiles/securitypolicies@2022-11-01-preview' = {
  parent: profile
  name: securityPolicyName
  properties: {
    parameters: {
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: securityPolicyDomains
          patternsToMatch: securityPolicyPatternsToMatch
        }
      ]
      type: securityPolicyType
    }
  }
}
