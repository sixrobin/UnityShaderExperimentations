Shader "Camera Depth"
{
    Properties
    {
        _DepthColorA ("Depth Color A", Color) = (1, 0, 0, 1)
        _DepthColorB ("Depth Color B", Color) = (0, 0, 0, 1)
        _FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1)
        _FresnelIntensity ("Fresnel Intensity", Range(0.1, 5)) = 1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
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
                float4 screen_space : TEXCOORD1;
                float3 normal       : TEXCOORD2;
                float3 viewDir      : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            float4 _DepthColorA;
            float4 _DepthColorB;
            float4 _FresnelColor;
            float _FresnelIntensity;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screen_space = ComputeScreenPos(o.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Compute depth.
                float2 screen_space_uv = i.screen_space.xy / i.screen_space.w;
                float depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screen_space_uv));

                // Color depth.
                float3 depth_color = lerp(_DepthColorA, _DepthColorB, depth);

                // Fresnel.
                float fresnel = saturate(pow(dot(i.viewDir, i.normal), _FresnelIntensity));

                // Final color.
                float3 color = lerp(lerp(_FresnelColor, depth_color, 1 - _FresnelColor.a), depth_color, fresnel);
                
                return fixed4(color, 1);
            }
            
            ENDCG
        }
    }
}
