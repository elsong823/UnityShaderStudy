Shader "MyShader/c6/halfLambertShader"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : NORMAL;
			};
			fixed4 _Diffuse;

			v2f vert(in appdata_base i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
//				o.worldNormal = mul(i.normal, _World2Object);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);

				return o;
			}

			fixed4 frag(in v2f i) : COLOR
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0);

				float diff = dot(worldLightDir, normalize(i.worldNormal)) * 0.5 + 0.5;
				fixed3 diffuse = _LightColor0 * _Diffuse * diff;
				fixed4 fragColor = fixed4(ambient + diffuse, 1.0);
				return fragColor;
			}



			ENDCG
		}
	}

	Fallback "Diffuse"
}