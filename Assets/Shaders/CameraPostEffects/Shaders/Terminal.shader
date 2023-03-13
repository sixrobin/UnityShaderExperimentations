// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Terminal" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_contour("Contour Size", float) = 0
		_vignette("Vignette Strength", float) = 0
		_intensity("Noise Strength", float) = 0
		_global("Global Illumination", float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
						
	sampler2D _MainTex;
	float _timer;
	float _contour;
	float _vignette;
	float _speed;
	float _intensity;
	float _global;
			
	struct appdata_t
    {
        float4 vertex   : POSITION;
        fixed4 color    : COLOR;
        half2 uv		: TEXCOORD0;
    };
 
    struct v2f
    {
        float4 vertex   : POSITION;
        fixed4 color    : COLOR;
		half2 uv		: TEXCOORD0;
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
		uv = (uv - 0.5) * 2.0;
		uv *= 1.1;	
		uv.x *= 1.0 + pow((abs(uv.y) * _contour/7), 2.0);
		uv.y *= 1.0 + pow((abs(uv.x) * _contour/5), 2.0);
		uv = (uv / 2.0) + 0.5;
		uv =  uv * 0.92 + 0.039;
		return uv;
	}

	fixed4 frag (v2f i) : COLOR
	{	
		float2 uv = i.uv.xy;;
		uv = curve( uv );
   
		float4 sum = (float4)0;
		sum = tex2D(_MainTex, float2(uv.x, uv.y));
				
		float x = uv.x * uv.y * _timer * 1000 + 10;
		x = fmod(x, 20) * fmod(x, 150);
		float dx = fmod(x, 0.01f);

		float3 parasite = (float3)0;
		parasite = sum.rgb + sum.rgb * saturate(0.001 + dx.xxx * 100);

		sum.g += cos(uv.y * 1111 + _Time.z * _speed * 10) * _intensity;
		sum.rgb *= dot(sum.xyz * parasite.xyz + sum.rgb, 1.0f) * 0.5f;

		float vignette = (float)0;
		vignette = (10.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
		sum *= pow(vignette, _vignette/2);

		sum /= _global;

		if (uv.x < 0.0 || uv.x > 1.0)
			sum = 0.025;
		if (uv.y < 0.0 || uv.y > 1.0)
			sum = 0.025;

		return fixed4(sum);
	}			
			
	ENDCG

	SubShader
	{
		pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
	Fallback off
}