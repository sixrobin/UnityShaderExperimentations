Shader "USB/Game Of Life"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
        [MaterialToggle] FlipGradient ("Flip Gradient", Float) = 0
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
            #pragma multi_compile_local _ FLIPGRADIENT_ON


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Ramp;
            float _FlipGradient;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed cellRemainingLifeTime = tex2D(_MainTex, i.uv).r;

                #if defined (FLIPGRADIENT_ON)
                return tex2D(_Ramp, float2(1 - cellRemainingLifeTime, 0));
                #else
                return tex2D(_Ramp, float2(cellRemainingLifeTime, 0));
                #endif
            }
            
            ENDCG
        }
    }
}
