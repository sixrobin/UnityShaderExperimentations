Shader "RSLib/InvertedFlash"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
            fixed _Percentage;
            fixed _Desaturate;
            fixed2 _DesaturationSmoothstep;

            v2f vert(const appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(const v2f i) : SV_Target
            {
                // Sample base color.
                fixed4 col = tex2D(_MainTex, i.uv);

                // Compute inverted and desaturated color.
                fixed4 inverted_col = 1 - col;
                fixed inverted_col_desaturated = Luminance(inverted_col).r;
                inverted_col_desaturated = smoothstep(_DesaturationSmoothstep.x, _DesaturationSmoothstep.y, inverted_col_desaturated);
                inverted_col = lerp(inverted_col, inverted_col_desaturated, _Desaturate);
                
                return lerp(col, inverted_col, _Percentage);
            }
            
            ENDCG
        }
    }
}