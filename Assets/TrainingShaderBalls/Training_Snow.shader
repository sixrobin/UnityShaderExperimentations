Shader "Training/Snow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "black" {}
        _SparklesTex ("Sparkles (R)", 2D) = "white" {}
        _SparklesScale ("Sparkles Scale", Range(1, 10)) = 1
        [Normal] _NormalMap ("Normal", 2D) = "white" {}
        _NormalIntensity ("Normal Intensity", Range(0, 1)) = 1
        [PowerSlider(4)] _FresnelIntensity ("Fresnel Intensity", Range(0.25, 4)) = 1
        _FresnelAlpha ("Fresnel Alpha", Range(0, 1)) = 1
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        
        LOD 200

        CGPROGRAM
        
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
            float3 worldNormal;
            float3 viewDir;
            float3 worldPos;
            INTERNAL_DATA
        };

        sampler2D _MainTex;
        sampler2D _SparklesTex;
        fixed _SparklesScale;
        sampler2D _NormalMap;
        fixed _NormalIntensity;
        fixed _FresnelIntensity;
        fixed _FresnelAlpha;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf(Input i, inout SurfaceOutputStandard o)
        {
            // Screen space sparkles.
            float2 screen_coords = float2(_ScreenParams.xy) / _ScreenParams.w / 256; // 256 is Sparkles tex size. Get dynamically?
            float2 screen_uv = screen_coords * (i.screenPos.xy / i.screenPos.w); 
            fixed sparkles_screen_space = tex2D(_SparklesTex, screen_uv).r;
            // Object space sparkles.
            fixed sparkles_object_space = tex2D(_SparklesTex, i.uv_MainTex * _SparklesScale).r;
            // Sparkles shadow mask.
            float shadow = 1;
            #if defined(SHADOWS_SCREEN) && !defined(UNITY_NO_SCREENSPACE_SHADOWS)
            shadow = unitySampleShadow(i.screenPos);
            #endif
            // Final sparkles computation.
            float sparkles = sparkles_screen_space * sparkles_object_space * shadow;
            
            // Normal.
            float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv_MainTex));
            normal.xy *= _NormalIntensity;

            // Fresnel.
            float fresnel = 1 - dot(normalize(i.viewDir), normal);
            fresnel = saturate(fresnel);
            fresnel = pow(fresnel, _FresnelIntensity);
            fresnel *= _FresnelAlpha;
            
            fixed4 color = tex2D(_MainTex, i.uv_MainTex) * _Color;
            
            o.Albedo = color.rgb;
            o.Normal = normal;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = color.a;
            o.Emission = sparkles + fresnel;
        }
        
        ENDCG
    }
    
    FallBack "Diffuse"
}
