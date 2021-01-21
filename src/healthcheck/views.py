from rest_framework.response import Response
from rest_framework.views import APIView


__all__ = 'Ping',


class Ping(APIView):
    """
    View for testing.
    """

    def get(self, request):
        return Response(data='Pong')
