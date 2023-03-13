// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/LCD" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_contour("Contour Size", float) = 1
		_vignette("Vignette Strength", float) = 1
		_intensity("Bright Intensity", float) = 0.5
		_resX("Screen Resolution X", int) = 1280
		_resY("Screen Resolution Y", int) = 720
	}

	CGINCLUDE
	#include "UnityCG.cginc"
						
	sampler2D _MainTex;
	float _contour;
	float _vignette;
	float _intensity;
	int _resX;
	int _resY;
			
	struct appdata_t
    {
        float4 vertex   : POSITION;
        float4 color    : COLOR;
        float2 uv		: TEXCOORD0;
    };
 
    struct v2f
    {
        half2 uv		: TEXCOORD0;
        float4 vertex   : SV_POSITION;
        fixed4 color    : COLOR;
    };   
             
  	v2f vert(appdata_t i)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(i.vertex);
        o.uv = i.uv;
        o.color = i.color;               
        return o;
    }

    inline float2 curve(float2 uv)
	{
		uv 		= (uv - 0.5) * 2.0;
		uv     *= 1.1;	
		uv.x   *= 1.0 + pow((abs(uv.y) * _contour/7), 2.0);
		uv.y   *= 1.0 + pow((abs(uv.x) * _contour/5), 2.0);
		uv 	 	= (uv / 2.0) + 0.5;
		uv 		=  uv * 0.92 + 0.039;
		return uv;
	}

	fixed4 frag(v2f i) : COLOR
	{
		float2 uv = i.uv.xy;
		uv = curve(uv);

		float4 sum = (float4)0;
		sum = tex2D(_MainTex,float2(uv.x, uv.y));

		float x = uv.x * uv.y * _Time * 1000 + 10;
		x = fmod(x, 20) * fmod(x, 150);
		float dx = fmod(x, 0.01f);

		float3 parasite = (float3)0;
		parasite = sum.rgb + sum.rgb * saturate(0.001 + dx.xxx * 100);

		float3 xxx = (float)0;
		xxx = tex2D(_MainTex, uv + parasite * 1 / 250);

		float2 sclinesX;
		sincos(uv.x * _resX, sclinesX.x, sclinesX.y);
		float2 sclinesY;
		sincos(uv.y * _resY, sclinesY.x, sclinesY.y);

		parasite += sum.rgb * float3(sclinesY.x * _intensity, sclinesY.y * _intensity, sclinesY.x * _intensity);
		parasite += sum.rgb * float3(sclinesX.x * _intensity, sclinesX.y * _intensity, sclinesX.x * _intensity);
		parasite = lerp(sum, parasite, saturate(_intensity));

		float3 col = (float3)0;
		col.rgb += sum.xyz / parasite.xyz;

		col.rgb += pow(col.rgb, 1);
		col.rgb *= col;
		col.rgb += col;

		float vignette = (float)0;
		vignette = (10 * uv.x * uv.y * (1 - uv.x) * (1 - uv.y));
		col *= pow(vignette, _vignette / 2);

		if (uv.x < 0.0 || uv.x > 1.0)
			col = 0.025;
		if (uv.y < 0.0 || uv.y > 1.0)
			col = 0.025;

		return fixed4(col * xxx, 1.0);
	}

	ENDCG

	SubShader
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0
			ENDCG
		}
	}
	fallback off
}
