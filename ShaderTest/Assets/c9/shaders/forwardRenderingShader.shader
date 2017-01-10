Shader "MyShader/c9/forwardRenderingShader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess("Shininess", Range(8,256)) = 128
	}

	SubShader
	{
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
			//必不可少，这样光照中衰减等光照变量才能被unity正常赋值
			#pragma multi_compile_fwdbase
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			fixed4 _Specular;
			float _Shininess;

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f Vert(in appdata_base i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldPos = mul(_Object2World, i.vertex).xyz;

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldView = normalize(_WorldSpaceCameraPos - i.worldPos);
				fixed3 worldHalf = normalize(worldLight + worldView);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldLight, worldNormal));

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldHalf, worldNormal)), _Shininess);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Specular"
}