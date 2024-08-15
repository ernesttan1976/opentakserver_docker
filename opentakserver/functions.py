import re
from datetime import datetime

ISO8601_FORMAT = "%Y-%m-%dT%H:%M:%S.%fZ"
ISO8601_FORMAT_NO_MICROSECONDS = "%Y-%m-%dT%H:%M:%SZ"
affiliations = ['friendly', 'hostile', 'unknown', 'pending', 'assumed', 'neutral', 'suspect', 'joker', 'faker']


def get_tasking(cot_type):
    if re.match("^t-x-f", cot_type):
        return "remarks"
    if re.match("^t-x-s", cot_type):
        return "state/sync"
    if re.match("^t-s", cot_type):
        return "required"
    if re.match("^t-z", cot_type):
        return "cancel"
    if re.match("^t-x-c-c", cot_type):
        return "commcheck"
    if re.match("^t-x-c-g-d", cot_type):
        return "dgps"
    if re.match("^t-k-d", cot_type):
        return "destroy"
    if re.match("^t-k-i", cot_type):
        return "investigate"
    if re.match("^t-k-t", cot_type):
        return "target"
    if re.match("^t-k", cot_type):
        return "strike"
    if re.match("^t-", cot_type):
        return "tasking"
    return None


def get_affiliation(cot_type):
    if re.match("^t-", cot_type):
        return get_tasking(cot_type)
    if re.match("^a-f-", cot_type):
        return "friendly"
    if re.match("^a-h-", cot_type):
        return "hostile"
    if re.match("^a-u-", cot_type):
        return "unknown"
    if re.match("^a-p-", cot_type):
        return "pending"
    if re.match("^a-a-", cot_type):
        return "assumed"
    if re.match("^a-n-", cot_type):
        return "neutral"
    if re.match("^a-s-", cot_type):
        return "suspect"
    if re.match("^a-j-", cot_type):
        return "joker"
    if re.match("^a-k-", cot_type):
        return "faker"
    return None


def get_battle_dimension(cot_type):
    if re.match("^a-.-A", cot_type):
        return "airborne"
    if re.match("^a-.-G", cot_type):
        return "ground"
    if re.match("^a-.-G-I", cot_type):
        return "installation"
    if re.match("^a-.-S", cot_type):
        return "surface/sea"
    if re.match("^a-.-U", cot_type):
        return "subsurface"
    return None


def parse_type(cot_type):
    if re.match("^a-.-G-I", cot_type):
        return "installation"
    if re.match("^a-.-G-E-V", cot_type):
        return "vehicle"
    if re.match("^a-.-G-E", cot_type):
        return "equipment"
    if re.match("^a-.-A-W-M-S", cot_type):
        return "sam"
    if re.match("^a-.-A-M-F-Q-r", cot_type):
        return "uav"


def cot_type_to_2525c(cot_type):
    mil_std_2525c = "s"
    cot_type_list = cot_type.split("-")
    cot_type_list.pop(0)  # this should always be letter a
    affiliation = cot_type_list.pop(0)
    battle_dimension = cot_type_list.pop(0)
    mil_std_2525c += affiliation
    mil_std_2525c += battle_dimension
    mil_std_2525c += "-"

    for letter in cot_type_list:
        if letter.isupper():
            mil_std_2525c += letter.lower()

    while len(mil_std_2525c) < 10:
        mil_std_2525c += "-"

    return mil_std_2525c


def datetime_from_iso8601_string(datetime_string):
    try:
        return datetime.strptime(datetime_string, ISO8601_FORMAT)
    except ValueError:
        return datetime.strptime(datetime_string, ISO8601_FORMAT_NO_MICROSECONDS)


def iso8601_string_from_datetime(datetime_object):
    return datetime_object.strftime("%Y-%m-%dT%H:%M:%S.%f"[:-3] + "Z")
