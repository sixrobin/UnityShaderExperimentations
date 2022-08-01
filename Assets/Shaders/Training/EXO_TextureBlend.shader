Shader "EXO/EXO_TextureBlend"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _SecondaryTex ("Secondary Texture", 2D) = "white" {}
        _SecondaryColor ("Secondary Color", Color) = (1, 1, 1, 1)
        
        [Header(BLEND)]
        [Space(5)]
        _BlendTex ("Blend Texture", 2D) = "white" {}
        _BlendAmount ("Blend Amount", Range(0, 1)) = 0
        _BlendSmooth ("Blend Smooth", Range(0, 0.5)) = 0.3
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv_main : TEXCOORD0;
                float2 uv_secondary : TEXCOORD1;
                float2 uv_blend : TEXCOORD3;
            };
            
            struct v2f
            {
                float2 uv_main : TEXCOORD0;
                float2 uv_secondary : TEXCOORD1;
                float2 uv_blend : TEXCOORD3;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;

            half4 _MainColor;
            half4 _SecondaryColor;
            
            sampler2D _BlendTex;
            float4 _BlendTex_ST;
            float _BlendAmount;
            float _BlendSmooth;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_main = TRANSFORM_TEX(v.uv_main, _MainTex);
                o.uv_secondary = TRANSFORM_TEX(v.uv_secondary, _SecondaryTex);
                o.uv_blend = TRANSFORM_TEX(v.uv_blend, _BlendTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 main_color = tex2D(_MainTex, i.uv_main);
                fixed4 secondary_color = tex2D(_SecondaryTex, i.uv_secondary);
                fixed4 blend_color = tex2D(_BlendTex, i.uv_main);

                fixed4 blend = smoothstep(blend_color - _BlendSmooth, blend_color + _BlendSmooth, _BlendAmount);
                
                return lerp(main_color * _MainColor, secondary_color * _SecondaryColor, blend);
            }
            
            ENDCG
        }
    }
}
