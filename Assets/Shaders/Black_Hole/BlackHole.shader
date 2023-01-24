Shader "BlackHole"
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
                float3 normal : NORMAL0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 fresnel : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float compute_fresnel(float3 normal, float3 view_direction, float power)
            {
                return pow(1.0 - saturate(dot(normalize(normal), normalize(view_direction))), power);
            }
            
            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                const float3 view_direction = normalize(ObjSpaceViewDir(v.vertex));
                const float dot_product = 1 - dot(v.normal, view_direction);
                o.fresnel = smoothstep(0, 1.0, dot_product) * fixed4(1, 1, 1, 1);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.fresnel, 1);
                return tex2D(_MainTex, i.uv);
            }
            
            ENDCG
        }
    }
}
