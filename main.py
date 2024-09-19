from vk_api.exceptions import VkApiError
from typing import List, Dict
import vk_api
import json
import datetime as dt

#Получить api для config файла:
#https://oauth.vk.com/authorize?client_id=5453402&display=page&redirect_uri=http://localhost&scope=&response_type=token&v=5.53

API_VERSION = "5.131"
POSTS_AT_A_TIME = 100  # VK API post count limit

with open("config.json", "r", encoding="utf-8") as config_file:
    f_data = json.load(config_file)

    ACCESS_TOKEN = f_data["access_token"]
    DOMAIN = f_data["domain"]

    POST_NUMBER = f_data["post_number"]

    del f_data


def get_max_offset(api) -> int:
    try:
        return api.method(
            method="wall.get",
            values={"domain": DOMAIN, "count": POSTS_AT_A_TIME}
        )["count"]
    except VkApiError:
        raise VkApiError("Invalid access token. How to get your own token: "
                         "https://dev.vk.com/api/access-token/getting-started")


def parse_wall_data(api, post_offset) -> List[Dict]:
    data = api.method(method="wall.get", values={
            "domain": DOMAIN,
            "offset": post_offset,
            "count": POSTS_AT_A_TIME
        })["items"]

    return [{
        "time": dt.datetime.fromtimestamp(int(post['date'])).strftime('%Y-%m-%d %H:%M:%S'),
        "likes": post["likes"]["count"],
        "id": post["id"]
    } for post in data]


def main():
    global POST_NUMBER

    api = vk_api.VkApi(token=ACCESS_TOKEN, api_version=API_VERSION)
    max_offset = get_max_offset(api)

    if not POST_NUMBER:
        POST_NUMBER = max_offset

    post_offset = 1
    n = 1
    with open("output.csv", "w", encoding="utf-8") as output_file:
        output_file.write('Post number from the beginning of the wall' + ";" + "Post id" + ";"
                          + "Publication date&time" + ";" + "Number of likes" + "\n")
        while (post_offset <= POST_NUMBER) and (post_offset <= max_offset):
            posts = parse_wall_data(api, post_offset)
            post_offset += POSTS_AT_A_TIME
            for post_data in posts:
                output_file.write(str(n) + ";" + str(post_data["id"]) + ";" +
                                  str(post_data["time"]) + ";" + str(post_data["likes"]) + "\n")
                n += 1


if __name__ == "__main__":
    main()
