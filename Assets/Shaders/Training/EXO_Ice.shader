Shader "EXO/EXO_Ice"
{
    Properties
    {
        _Tint ("Tint", Color) = (1,1,1,1)
        _MainTex ("Ice Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _CracksTexture ("Cracks Texture (packed RGB)", 2D) = "white" {}
        _StrengthXYZScaleW ("Strengths (XYZ) - Depth Scale (W)", Vector) = (6,3,1,1)
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_Roughness ("Ice Roughness Texture", 2D) = "black" {}
        _RoughnessStrength ("Roughness Strength", Range(0, 1)) = 0.4
        _RotationSpeed ("Rotation Speed", Range(0, 45)) = 1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
 
        CGPROGRAM
        
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.0

        fixed4 _Tint;
        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _CracksTexture;
        half4 _StrengthXYZScaleW;
        half _RoughnessStrength;
        sampler2D _Roughness;

        fixed _RotationSpeed;
        
        struct Input
        {
            float2 uv_MainTex;
            float3 view_direction_tangent;
        };
 
        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            
            float4 object_space_camera = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
            float3 view_direction = v.vertex - object_space_camera;
            float tangent_sign = v.tangent.w * unity_WorldTransformParams.w;
            float3 bitangent = cross(v.normal, v.tangent) * tangent_sign;
            
            o.view_direction_tangent = float3(dot(view_direction, v.tangent.xyz), dot(view_direction, bitangent.xyz), dot(view_direction, v.normal.xyz));
        }
 
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_MainTex + float2(_RotationSpeed * _Time.x, 0);
            
            fixed4 color = tex2D(_MainTex, uv) * _Tint;
            fixed3 normal = UnpackNormal(tex2D(_NormalMap, uv));
            fixed roughness = tex2D(_Roughness, uv).r * _RoughnessStrength;

            // Cracks (parallax effect).
            fixed cracks = 0;
            float2 uv_parallax = uv;
            float3 tangent = normalize(IN.view_direction_tangent);
            cracks += tex2D(_CracksTexture, uv_parallax + lerp(0, _StrengthXYZScaleW.w, 0.25) * tangent + normal).g * _StrengthXYZScaleW.x;
            cracks += tex2D(_CracksTexture, uv_parallax + lerp(0, _StrengthXYZScaleW.w, 0.50) * tangent + normal).b * _StrengthXYZScaleW.y;
            cracks += tex2D(_CracksTexture, uv_parallax + lerp(0, _StrengthXYZScaleW.w, 0.75) * tangent + normal).r * _StrengthXYZScaleW.z;
            cracks *= 1.5;
 
            color = lerp(color, color * cracks, 0.5);
            
            o.Albedo = color;
            o.Normal = normal;
            o.Smoothness = 1 - roughness;
        }
        
        ENDCG
    }
    
    FallBack "Diffuse"
}
