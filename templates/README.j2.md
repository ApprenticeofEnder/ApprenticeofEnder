<div style="visbility:hidden;">
    {%- macro icon(item) -%}
    <a href="{{ item.href }}" target="_blank" rel="noopener noreferrer"><img src="{{ item.image }}" height="40" width="40" alt="{{ item.alt }}"/></a>
    {%- endmacro -%}
    {%- macro tablerow(key) -%}
    <td>
        {%- for language in languages[key] %}
        {{ icon(language) }}
        {%- endfor %}
    </td>
    <td>
        {%- for framework in frameworks[key] %}
        {{ icon(framework) }}
        {%- endfor %}
    </td>
    <td>
        {%- for tool in tools[key] %}
        {{ icon(tool) }}
        {%- endfor %}
    </td>
    {%- endmacro -%}
</div>

<div align="center">
  <img height="300" src="{{ pfp_image }}" />
</div>

###

<div align="center">
  <a href="{{ linkedin }}">
    <img src="https://img.shields.io/static/v1?message=LinkedIn&logo=linkedin&label=&color=black&logoColor=chartreuse&labelColor=chartreuse&style=for-the-badge" height="25" alt="LinkedIn logo" />
  </a>
  <a href="{{ website }}">
    <img src="https://img.shields.io/static/v1?message=robertbabaev.tech&logo=firefox&label=&color=black&logoColor=black&labelColor=chartreuse&style=for-the-badge" height="25" alt="Website"/>
  </a>
</div>

###

<div align="center">
  <img src="https://komarev.com/ghpvc/?username=ApprenticeofEnder&color=brightgreen&style=for-the-badge&base=112"  />
</div>

###

<h1 align="center">{{ name }}</h1>

###

<div align="center">
  <img src="https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExZGtwYWExcjRneXl2ZmFoZDEzanFuYmc0Y3NxenF1dWVsY3lnc2xlMSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/zyFcsWHX2fdpyb5SBi/giphy.gif" width="100%"  />
  <p>Let's get to work.</p>
</div>

### About Me

Hey! My name is Robert, a Security Software Engineer from Canada.

<div class="tg-wrap">
    <table>
        <thead>
            <tr>
                <th>Languages</th>
                <th>Frameworks & Libraries</th>
                <th>Tools</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td colspan="3" align="center">
                    <b>
                        Favourites 
                    </b>
                </td>
            </tr>
            <tr>
                {{ tablerow("favourites") }}
            </tr>
            <tr>
                <td colspan="3" align="center">
                    <b>
                        Actively Using 
                    </b>
                </td>
            </tr>
            <tr>
                <td>
                    {%- for language in languages.actively_using %}
                    {{ icon(language) }}
                    {%- endfor %}
                </td>
                <td>
                    {%- for framework in frameworks.actively_using %}
                    {{ icon(framework) }}
                    {%- endfor %}
                </td>
                <td>
                    {%- for tool in tools.actively_using %}
                    {{ icon(tool) }}
                    {%- endfor %}
                </td>
            </tr>
            <tr>
                <td colspan="3" align="center">
                    <b>
                        Previous
                    </b>
                </td>
            </tr>
            <tr>
                <td>
                    {%- for language in languages.previous %}
                    {{ icon(language) }}
                    {%- endfor %}
                </td>
                <td>
                    {%- for framework in frameworks.previous %}
                    {{ icon(framework) }}
                    {%- endfor %}
                </td>
                <td>
                    {%- for tool in tools.previous %}
                    {{ icon(tool) }}
                    {%- endfor %}
                </td>
            </tr>
        </tbody>
    </table>
</div>
