// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Computer" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "" {}
		_contour("Contour Size", float) = 1
		_vignette("Vignette Strength", float) = 1
		_speed("Time Controller", float) = 0.5
		_noise("Noise Force", float) = 0.5
		_colorBG("BackGround Color", float) = 1
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float _contour;
	float _vignette;
	float _speed;
	float _noise;
	float4 _colorBG;

	struct appdata_t
	{
		float4 vertex   : POSITION;
		float4 color    : COLOR;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		half2 uv  : TEXCOORD0;
		float4 vertex   : SV_POSITION;
		fixed4 color : COLOR;
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
		uv.x *= 1.0 + pow((abs(uv.y) * _contour / 7), 2.0);
		uv.y *= 1.0 + pow((abs(uv.x) * _contour / 5), 2.0);
		uv = (uv / 2.0) + 0.5;
		uv = uv * 0.92 + 0.039;
		return uv;
	}

	float4 frag(v2f i) : SV_Target
	{
		float2 uv = i.uv.xy;
		uv = curve(uv);

		float4 sum = (float4)0;
		sum = tex2D(_MainTex,float2(uv.x, uv.y));

		float x = uv.x * uv.y * _Time.z * 1000 + 10;
		x = fmod(x, 20) * fmod(x, 150);
		float dx = fmod(x, 0.01);

		float3 noise = (float3)0;
		noise = sum.rgb + sum.rgb * _noise * saturate(0.2 + dx.xxx * 100);

		sum.r += cos(uv.y * 1111 + _Time.z * _speed * 10) * 0.33;
		sum.g += cos(uv.y * 999 + _Time.z * _speed * 10) * 0.22;
		sum.b += cos(uv.y * 888 + _Time.z * _speed * 10) * 0.11;

		sum.rgb *= dot(sum.xyz * noise.xyz + sum.rgb, 1.) * 0.5;

		float vignette = (float)0;
		vignette = (10 * uv.x * uv.y * (1 - uv.x) * (1 - uv.y));
		sum *= pow(vignette, _vignette/2);

		if (uv.x < 0 || uv.x > 1)
			sum = 0.01;
		if (uv.y < 0 || uv.y > 1)
			sum = 0.01;

		float3 vision = (float3)0;
		vision = _colorBG;

		return fixed4((sum + (noise * 0.1)) * vision, 1);
	}

	ENDCG

	Subshader 
	{
		Pass
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
