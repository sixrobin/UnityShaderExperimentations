Shader "Lighting/Diffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightIntensity ("Light Intensity", Range(0, 1)) = 1
        _AmbientColorIntensity ("Ambient Color Intensity", Range(0, 1)) = 1
        
        [Header(SPECULAR)]
        _SpecularTexture ("Specular Texture", 2D) = "black" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 1)) = 1
        _SpecularPower ("Specular Power", Range(1, 128)) = 64
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase"
        }
        
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv           : TEXCOORD0;
                float4 vertex       : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _LightIntensity;
            uniform float4 _LightColor0;
            float _AmbientColorIntensity;

            sampler2D _SpecularTexture;
            float _SpecularIntensity;
            float _SpecularPower;
            
            float3 lambert(float3 reflection_color, float light_intensity, float3 normal, float3 light_direction)
            {
                return reflection_color * light_intensity * max(0, dot(normal, light_direction));
            }

            float3 specular(float3 reflection_color, float intensity, float3 normal, float3 light_direction, float3 vertex_world, float power)
            {
                float3 view_direction = normalize(_WorldSpaceCameraPos - vertex_world);
                float3 halfway = normalize(light_direction + view_direction);
                return reflection_color * intensity * pow(max(0, dot(normalize(normal), halfway)), power);
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 normal = (i.normal_world + 1) * 0.5;
                float3 light_color = _LightColor0.rgb;
                float3 light_direction = normalize(_WorldSpaceLightPos0.xyz);
                
                float3 diffuse_shading = lambert(light_color, _LightIntensity, normal, light_direction);
                float3 specular_highlight = specular(light_color, _SpecularIntensity, i.normal_world, light_direction, i.vertex_world, _SpecularPower);

                float4 col = tex2D(_MainTex, i.uv);
                col.rgb *= diffuse_shading.r;
                col.rgb += UNITY_LIGHTMODEL_AMBIENT * (1 - diffuse_shading.r) * _AmbientColorIntensity;
                col.rgb += specular_highlight;
                
                return col;
            }
            
            ENDCG
        }
    }
}
