Shader "Training/WaterPlane"
{
    Properties
    {
        _DepthColorA ("Depth Color A", Color) = (0, 1, 1, 1)
        _DepthColorB ("Depth Color B", Color) = (0, 0, 1, 1)
        _FoamStep ("Foam Step", Range(0, 1)) = 0.5
        _FoamColor ("Foam Color", Color) = (1, 1, 1, 1)
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
            float _FoamStep;
            float4 _FoamColor;
            
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

                // Foam.
                float foam = step(_FoamStep, 1 - depth);
                
                return fixed4(depth_color + foam * _FoamColor, 1);
            }
            
            ENDCG
        }
    }
}
