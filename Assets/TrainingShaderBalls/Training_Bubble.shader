Shader "Training/Bubble"
{
    Properties
    {
        [NoScaleOffset] _SoapTexture ("Soap Texture", 2D) = "white" {}
        [NoScaleOffset] _ThicknessGradient ("Thickness Gradient", 2D) = "white" {}
        _ThicknessGradientRemapMin ("Thickness Gradient Remap Min", Range(0, 1)) = 0
        _ThicknessGradientRemapMax ("Thickness Gradient Remap Max", Range(0, 1)) = 1
        _SoapPatternScrollSpeed ("Soap Pattern Scroll Speed", Range(0, 1)) = 0.2
        _SoapPatternIntensity ("Soap Pattern Intensity", Range(0, 1)) = 0.1
        _SoapPatternScale ("Soap Pattern Scale", Range(0, 3)) = 1
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _FresnelIntensity ("Fresnel Intensity", Range(0, 10)) = 1
        _FresnelMultiplier ("Fresnel Multiplier", Range(0, 10)) = 1
        _MinAlpha ("Min Alpha", Range(0, 1)) = 0.1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        
        CGPROGRAM
        
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade
        #pragma target 3.0

        struct Input
        {
            float2 uv_SoapTexture;
            float3 viewDir;
            float3 worldNormal;
            float3 worldPos;
            float NdotL;
        };

        struct TriplanarUV
        {
	        float2 x;
            float2 y;
            float2 z;
        };

        sampler2D _SoapTexture;
        sampler2D _ThicknessGradient;
        half _SoapPatternScrollSpeed;
        half _SoapPatternIntensity;
        half _SoapPatternScale;
        half _ThicknessGradientRemapMin;
        half _ThicknessGradientRemapMax;
        half _Glossiness;
        half _FresnelIntensity;
        half _FresnelMultiplier;
        half _MinAlpha;

        float Remap(float value, float from1, float to1, float from2, float to2)
        {
            return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
        }

        TriplanarUV GetTriplanarUV(float3 worldPosition)
        {
	        TriplanarUV uv;
	        uv.x = worldPosition.zy;
	        uv.y = worldPosition.xz;
	        uv.z = worldPosition.xy;
	        return uv;
        }

        float3 GetTriplanarWeights(float3 normal)
        {
            float3 weight = abs(normal);
	        return weight / (weight.x + weight.y + weight.z);
        }
        
        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            
            float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            o.worldNormal = mul(unity_ObjectToWorld, v.normal);
            float NdotL = dot(o.worldNormal, lightDirection);
            NdotL = Remap(NdotL, -1, 1, _ThicknessGradientRemapMin, _ThicknessGradientRemapMax);

            o.viewDir = WorldSpaceViewDir(v.vertex);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex);
            o.NdotL = NdotL;
        }
        
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            TriplanarUV triplanarUV = GetTriplanarUV(IN.worldPos);
            float3 triplanarWeights = GetTriplanarWeights(IN.worldNormal);
            float scroll = _Time.x * _SoapPatternScrollSpeed;
	        float soapX = tex2D(_SoapTexture, triplanarUV.x * _SoapPatternScale + scroll).r;
	        float soapY = tex2D(_SoapTexture, triplanarUV.y * _SoapPatternScale + scroll).r;
	        float soapZ = tex2D(_SoapTexture, triplanarUV.z * _SoapPatternScale + scroll).r;
            float soap = ((soapX * triplanarWeights.x + soapY * triplanarWeights.y + soapZ * triplanarWeights.z) - 0.5) * _SoapPatternIntensity;
            
            fixed4 color = tex2D(_ThicknessGradient, float2(IN.NdotL + soap, 0));

            float fresnel = 1 - dot(normalize(IN.viewDir), IN.worldNormal);
            fresnel = saturate(fresnel);
            fresnel = pow(fresnel, _FresnelIntensity) * _FresnelMultiplier;

            o.Albedo = color.rgb + fresnel;
            o.Metallic = 1;
            o.Smoothness = _Glossiness;
            o.Alpha = saturate(fresnel + _MinAlpha);
        }
        
        ENDCG
    }
    
    FallBack "Diffuse"
}
