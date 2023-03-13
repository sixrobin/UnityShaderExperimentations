Shader "EXO/EXO_Lighting_Base"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float3 compute_normal_world(float3 normal)
            {
                return normalize(mul(unity_ObjectToWorld, float4(normal, 0))).xyz;
            }

            float dot_product(float3 a, float3 b)
            {
                return a.x * b.x + a.y * b.y + a.z * b.z;
            }

            float3 cross_product(float3 a, float3 b)
            {
                return a.yzx * b.zxy - a.zxy * b.yzx;
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = compute_normal_world(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float n_dot_l = (dot(i.normal, float3(1,1,1)) + 1) * 0.5;
                return float4(n_dot_l.xxx, 1);
            }
            
            ENDCG
        }
    }
}
