Shader "USB/Shell Layer"
{
    Properties
    {
        _Mask ("Mask", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        
        Cull Off
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
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _Mask;
            float4 _Mask_ST;
            float4 _Mask_TexelSize;
            float4 _Color;
            float _Radius;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 mask = tex2D(_Mask, i.uv);
                clip(mask - 0.5);

                float2 maskCellUV = (frac(i.uv / _Mask_TexelSize.xy) - 0.5) * 2;
                clip(_Radius - length(maskCellUV));

                return _Color;
            }
            
            ENDCG
        }
    }
}
